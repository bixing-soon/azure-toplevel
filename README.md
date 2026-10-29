# azure-toplevel

Subscription-scope Bicep for top-level resources. These include resource groups, storage account behind a private endpoint, and the shared VNet + private DNS zone.

## What gets deployed

| Resource | Name | Resource group |
|---|---|---|
| Resource groups | `rg-tfstate`, `rg-vnet`, `rg-email` | subscription |
| Storage account | `bixingsttfstate` | index 0 |
| Private endpoint (one per account) | `pe-<account>-blob` | index 0 |
| VNet + subnet | `vnet-toplevel` (`10.100.0.0/16`), `snet-private-endpoints` (`10.100.1.0/24`) | index 1 |
| Private DNS zone + VNet link | `privatelink.blob.core.windows.net` | index 1 |

`rGroupNames` is positional: index 0 = storage accounts + endpoints, index 1 = VNet + DNS zone.

## Deploy

Open the devcontainer, or install `az` + Bicep (`az bicep install`).

```bash
az login
az account set --subscription "<subscription name or id>"

az deployment sub create -n <deployment-name> -l australiaeast \
  -f main.bicep -p parameters/main.bicepparam --what-if
# drop --what-if to apply
```

Outputs: `resourceGroupNames`, `storageAccountNames`, `vnetId`
(`az deployment sub show -n <deployment-name> --query properties.outputs`).

## Parameters

| Parameter | Purpose |
|---|---|
| `location` | Region for everything. Australian regions only: `australiaeast`, `australiasoutheast`, `australiacentral` |
| `rGroupNames` | Resource groups to create; positional, see above |
| `stAccNames` | Storage account names (3-24 lowercase alphanumeric, globally unique) |
| `stAccSkuName` / `stAccKind` / `stAccAccessTier` | Account SKU / kind / blob tier |
| `vnetName` / `vnetAddressPrefix` | VNet name and address space |
| `vnetSubnets` | Subnets to create in the VNet, as `{ name, addressPrefix }` objects |
| `vnetPeSubnetName` | Which subnet hosts the private endpoints (must match a `vnetSubnets` entry) |
| `privateDnsZoneName` | `privatelink.blob.core.windows.net` |

All parameters are required - values live in `parameters/main.bicepparam`.

## Networking

Storage accounts are private-only: `publicNetworkAccess: 'Disabled'`, ACL `Deny`, Entra ID only. Each account gets a private endpoint, and its A record is registered automatically by the endpoint's DNS zone group.

The blob FQDN resolves only inside the VNet. Auth is Entra ID for Terraform so `az storage ... --auth-mode login`, or `use_azuread_auth = true` in the Terraform azurerm backend.

Cost: ~$0.01/hr per private endpoint, plus ~$0.50/mo for the DNS zone. There is also egress fees for traffic leaving the VNet.

## Scripts

| Script | What it does |
|---|---|
| `scripts/create-sp.sh` | `az ad sp create-for-rbac --create-cert`; writes a `.pem` (local/CI use only) |
| `scripts/setup-git.sh` | Git identity, SSH commit signing, `safe.directory` |

Generated `*.pem` / `*.pfx` / `*.key` / `age-key.txt` files are git-ignored. Plz never commit a credential.
