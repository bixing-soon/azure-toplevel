# azure-toplevel

Top-level Azure resources for the subscription. Bicep bootstraps the minimum Terraform needs; Terraform owns everything else.

| Managed by | Resources |
|---|---|
| Bicep (`main.bicep`) | `rg-tfstate` + the Terraform state storage account |
| Terraform (`terraform/`) | Resource groups (`rg-vnet`, `rg-email`, `rg-gpu_vm`), VNet + subnets, CI app registrations, federated credentials, role assignments, custom SMTP role |

Bicep is deliberately limited to the bootstrap: the state account must exist before Terraform can store state, and Terraform must not own it - a `terraform destroy` would delete its own backend. It also means `rg-tfstate` is the only resource group that must be deployed before `terraform apply`.

## Deploy

Bicep first:

```bash
az login
az account set --subscription "<subscription name or id>"

az deployment sub create -n <deployment-name> -l australiaeast \
  -f main.bicep -p parameters/main.bicepparam --what-if
# drop --what-if to apply
```

Then Terraform:

```bash
cd terraform
terraform init
terraform apply -var="forgejo_url=https://forgejo.example.com"

terraform output identity_client_ids
terraform output -raw smtp_client_secret       # store as a Forgejo secret
```

## Bicep parameters

| Parameter | Purpose |
|---|---|
| `location` | Region for everything. Australian regions only: `australiaeast`, `australiasoutheast`, `australiacentral` |
| `rGroupName` | Resource group for the state storage account (`rg-tfstate`). Terraform creates the rest |
| `stAccNames` | Storage account names (3-24 lowercase alphanumeric, globally unique) |
| `stAccSkuName` / `stAccKind` / `stAccAccessTier` | Account SKU / kind / blob tier |
| `stAccPublicNetworkAccess` | `Enabled` or `Disabled`. Entra ID is required either way |

All parameters are required - values live in `parameters/main.bicepparam`.

## Terraform variables

| Variable | Default | Purpose |
|---|---|---|
| `forgejo_url` | — (required) | Forgejo base URL, e.g. `https://forgejo.example.com` |
| `forgejo_repo` | `bixing/azure-toplevel` | OIDC subject repo; Forgejo >= 16 uses numeric IDs |
| `forgejo_branch` | `main` | Branch the OIDC subject is pinned to |
| `location` | `australiaeast` | Region for the Terraform-managed resource groups and VNet |
| `rg_tfstate` | `rg-tfstate` | Existing RG created by Bicep (data source, not managed) |
| `rg_vnet` / `rg_email` / `rg_gpu` | `rg-vnet` / `rg-email` / `rg-gpu_vm` | Resource groups Terraform creates |
| `vnet_name` / `vnet_address_prefix` | `vnet-toplevel` / `10.100.0.0/16` | VNet name and address space |
| `vnet_subnets` | `{ snet-gpu_vm = "10.100.1.0/24" }` | Map of subnet name to prefix |
| `smtp_role_name` | `ACS SMTP Sender` | Custom role for the SMTP identity |

## CI identities

| Identity | Scope | Role | Credential |
|---|---|---|---|
| `azure-toplevel-tfstate` | `rg-tfstate` | `Storage Blob Data Contributor` | Forgejo OIDC |
| `azure-toplevel-email` | `rg-email` | `Communication and Email Service Owner` | Forgejo OIDC |
| `azure-toplevel-smtp` | `rg-email` | custom `ACS SMTP Sender` | client secret (the SMTP password) |
| `azure-toplevel-gpu` | `rg-gpu_vm` | `Virtual Machine Contributor` | Forgejo OIDC |

Requires an Entra *Application Administrator* or *Cloud Application Administrator* role for the app registrations, plus *Owner* or *User Access Administrator* on the resource groups. The state file holds the SMTP client secret in plaintext - keep it off-repo (git-ignored) or enable the commented `azurerm` backend in `terraform/providers.tf`.

The OIDC subject is `repo:<owner>/<repo>:ref:refs/heads/<branch>`; Forgejo >= 16 uses numeric IDs in that string (`owner-123/repo-456`), so set `forgejo_repo` accordingly if the credential is rejected.

```yaml
enable-openid-connect: true

jobs:
  deploy:
    runs-on: docker
    steps:
      - id: token
        run: |
          token=$(curl -sS -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
            "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=api://AzureADTokenExchange" | jq -r .value)
          echo "ARM_OIDC_TOKEN=$token" >> "$FORGEJO_ENV"
      - run: terraform plan
        env:
          ARM_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: 'true'
```

For the split-identity setup, use `-backend-config="client_id=...","oidc_token=$token"` for the state SP and `ARM_*` for the deploy SP.

## Scripts

| Script | What it does |
|---|---|
| `scripts/create-sp.sh` | `az ad sp create-for-rbac --create-cert`; writes a `.pem` (local development use only) |
| `scripts/setup-git.sh` | Git identity, SSH commit signing, `safe.directory` |

Generated `*.pem` / `*.pfx` / `*.key` / `age-key.txt` files are git-ignored. Never commit a credential.
