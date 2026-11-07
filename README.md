# azure-toplevel

Subscription-scope Bicep for top-level resources: resource groups, a storage account locked to Entra ID authentication, and the shared VNet.

## What gets deployed

| Resource | Name | Resource group |
|---|---|---|
| Resource groups | `rg-tfstate`, `rg-vnet`, `rg-email`, `rg-gpu_vm` | subscription |
| Storage account | `bixingsttfstate` | index 0 |
| VNet + subnet | `vnet-toplevel` (`10.100.0.0/16`), `snet-pe` (`10.100.1.0/24`) | index 1 |

`rGroupNames` is positional: index 0 = storage accounts, index 1 = VNet.

## Deploy

Open the devcontainer, or install `az` + Bicep (`az bicep install`).

```bash
az login
az account set --subscription "<subscription name or id>"

az deployment sub create -n <deployment-name> -l australiaeast \
  -f main.bicep -p parameters/main.bicepparam --what-if
# drop --what-if to apply
```

Outputs: `resourceGroupNames`, `storageAccountNames`, `vnetId`.

## Parameters

| Parameter | Purpose |
|---|---|
| `location` | Region for everything. Australian regions only: `australiaeast`, `australiasoutheast`, `australiacentral` |
| `rGroupNames` | Resource groups to create; positional, see above |
| `stAccNames` | Storage account names (3-24 lowercase alphanumeric, globally unique) |
| `stAccSkuName` / `stAccKind` / `stAccAccessTier` | Account SKU / kind / blob tier |
| `stAccPublicNetworkAccess` | `Enabled` or `Disabled`. Entra ID is required either way; `Disabled` has no network path in this template |
| `vnetName` / `vnetAddressPrefix` | VNet name and address space |
| `vnetSubnets` | Subnets to create in the VNet, as `{ name, addressPrefix }` objects |

All parameters are required, please fill them in `parameters/main.bicepparam`.

## Scripts

| Script | What it does |
|---|---|
| `scripts/create-sp.sh` | `az ad sp create-for-rbac --create-cert`; writes a `.pem` (local development use only) |
| `scripts/setup-git.sh` | Git identity, SSH commit signing, `safe.directory` |

Generated `*.pem` / `*.pfx` / `*.key` / `age-key.txt` files are git-ignored. Never commit a credential.
