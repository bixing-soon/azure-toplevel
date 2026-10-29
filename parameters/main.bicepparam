using '../main.bicep'

param rGroupLocation = 'australiaeast'
param rGroupNames = [
  'rg-tfstate' // keep this at the top to not break rGroupNames[0]
  'rg-email'
]

param stAccNames = [
  'bixingsttfstate'
]
param stAccSkuName = 'Standard_LRS'
param stAccKind = 'StorageV2'
param stAccAccessTier = 'Hot'
