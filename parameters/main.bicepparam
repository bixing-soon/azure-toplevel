using '../main.bicep'

param location = 'australiaeast'
param rGroupName = 'rg-tfstate'
param stAccNames = [
  'bixingsttfstate'
]
param stAccSkuName = 'Standard_LRS'
param stAccKind = 'StorageV2'
param stAccAccessTier = 'Hot'
param stAccPublicNetworkAccess = 'Enabled'
