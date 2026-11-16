variable "forgejo_url" {
  description = "Base URL of the Forgejo instance"
  type        = string
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "forgejo_repo" {
  type    = string
  default = "bixing/azure-toplevel"
}

variable "forgejo_branch" {
  type    = string
  default = "main"
}

variable "rg_tfstate" {
  description = "Name of the resource group for storing Terraform state."
  type        = string
  default     = "rg-tfstate"
}

variable "resource_groups" {
  type = set(string)
  default = [
    "rg-vnet",
    "rg-email",
    "rg-gpu_vm"
  ]
}

variable "vnet_name" {
  type    = string
  default = "vnet-toplevel"
}

variable "vnet_address_prefix" {
  type    = string
  default = "10.100.0.0/16"
}

variable "vnet_subnets" {
  description = "Prefixes must fit inside vnet_address_prefix and must not overlap."
  type        = map(string)
  default = {
    snet-gpu_vm = "10.100.1.0/24"
  }
}

variable "smtp_role_name" {
  description = "Name of the custom role used by the SMTP identity."
  type        = string
  default     = "ACS SMTP Sender"
}
