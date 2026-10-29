# azure-toplevel

Bicep templates for the **top-level** Azure subscription resources that everything else bootstraps from. This includes resource groups, storage accounts, blob containers and Entra ID objects.

Subscription-scope only.

## Quick start

Either open the repo in the devcontainer, or locally with `az` + Bicep
(`az bicep install`).

```bash
az login
az account set --subscription "<subscription name or id>"

az deployment sub create \
  --location australiaeast \
  --template-file main.bicep \
  --parameters parameters/main.bicepparam \
  --what-if

az deployment sub create \
  --location australiaeast \
  --template-file main.bicep \
  --parameters parameters/main.bicepparam
```

Use `--name <deployment-name>` for repeatable names (e.g. `rg-toplevel-dev-01`),
and `az deployment sub show --name <name> --query properties.outputs` to read
what was created.

## Parameters

| Parameter | Default | Purpose |
|---|---|---|
| `rGroupLocation` | `australiaeast` | Region for the resource group metadata |
| `rGroupNames` | — (required) | Names of the resource groups to create |
| `stAccNames` | — (required) | Storage account names (3-24 lowercase alphanumeric chars, globally unique) |
| `stAccSkuName` | `Standard_LRS` | Storage account SKU |
| `stAccKind` | `StorageV2` | Storage account kind |
| `stAccAccessTier` | `Hot` | Blob access tier |

## Scripts

| Script | What it does |
|---|---|
| `scripts/create-sp.sh` | `az ad sp create-for-rbac ... --create-cert` writes a `.pem` and prints the appId/tenant. `--create-cert` is for local/CI credential use only. |
| `scripts/setup-git.sh` | Configures git identity, SSH commit signing and `safe.directory`. |

The generated `*.pem` / `*.pfx` / `*.key` / `age-key.txt` files are git-ignored.
Plz never commit a credential.
