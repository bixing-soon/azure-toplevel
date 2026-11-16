data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "tfstate" {
  name = var.rg_tfstate
}

resource "azurerm_resource_group" "resource_groups" {
  for_each = var.resource_groups
  name     = each.key
  location = var.location
}

locals {
  issuer  = "${trimsuffix(var.forgejo_url, "/")}/api/actions"
  subject = "repo:${var.forgejo_repo}:ref:refs/heads/${var.forgejo_branch}"

  rg_vnet  = azurerm_resource_group.resource_groups["rg-vnet"]
  rg_email = azurerm_resource_group.resource_groups["rg-email"]
  rg_gpu   = azurerm_resource_group.resource_groups["rg-gpu_vm"]

  oidc_identities = {
    tfstate = {
      display_name = "azure-toplevel-tfstate"
      scope        = data.azurerm_resource_group.tfstate.id
      role         = "Storage Blob Data Contributor"
    }
    email = {
      display_name = "azure-toplevel-email"
      scope        = local.rg_email.id
      role         = "Communication and Email Service Owner"
    }
    gpu = {
      display_name = "azure-toplevel-gpu"
      scope        = local.rg_gpu.id
      role         = "Virtual Machine Contributor"
    }
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = local.rg_vnet.location
  resource_group_name = local.rg_vnet.name
  address_space       = [var.vnet_address_prefix]
}

resource "azurerm_subnet" "this" {
  for_each             = var.vnet_subnets
  name                 = each.key
  resource_group_name  = local.rg_vnet.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azuread_application" "oidc" {
  for_each         = local.oidc_identities
  display_name     = each.value.display_name
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "oidc" {
  for_each  = azuread_application.oidc
  client_id = each.value.client_id
}

resource "azuread_application_federated_identity_credential" "forgejo" {
  for_each       = azuread_application.oidc
  application_id = each.value.id
  display_name   = "forgejo-${var.forgejo_branch}"
  issuer         = local.issuer
  subject        = local.subject
  audiences      = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "oidc" {
  for_each             = local.oidc_identities
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = azuread_service_principal.oidc[each.key].object_id
  principal_type       = "ServicePrincipal"
}

# client secret is SMTP password, so must use password auth
resource "azuread_application" "smtp" {
  display_name     = "azure-toplevel-smtp"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "smtp" {
  client_id = azuread_application.smtp.client_id
}

resource "azuread_application_password" "smtp" {
  application_id = azuread_application.smtp.id
  display_name   = "smtp"
  end_date       = timeadd(plantimestamp(), "8760h")
  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "azurerm_role_definition" "smtp" {
  name        = var.smtp_role_name
  scope       = local.rg_email.id
  description = "Send email through Azure Communication Services over SMTP."
  permissions {
    actions = [
      "Microsoft.Communication/CommunicationServices/Read",
      "Microsoft.Communication/CommunicationServices/Write",
      "Microsoft.Communication/EmailServices/Write",
    ]
    not_actions = []
  }
  assignable_scopes = [local.rg_email.id]
}

resource "azurerm_role_assignment" "smtp" {
  scope              = local.rg_email.id
  role_definition_id = azurerm_role_definition.smtp.role_definition_resource_id
  principal_id       = azuread_service_principal.smtp.object_id
  principal_type     = "ServicePrincipal"
}
