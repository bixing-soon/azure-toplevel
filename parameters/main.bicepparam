using '../main.bicep'

// ______________________________________________________
// Resource Group:

param location = 'australiaeast'
param rGroupNames = [
  'rg-tfstate' // index 0: storage acc + private endpoints
  'rg-vnet' // index 1: vnet + private DNS zone
  'rg-email'
]

// ______________________________________________________
// Storage Account:

param stAccNames = [
  // st acc names must be unique and not include any special chars
  'bixingsttfstate'
]
param stAccSkuName = 'Standard_LRS'
param stAccKind = 'StorageV2'
param stAccAccessTier = 'Hot'

// ______________________________________________________
// Virtual Network:

param vnetName = 'vnet-toplevel'
param vnetAddressPrefix = '10.100.0.0/16'
param vnetSubnets = [{
  name: 'snet-private-endpoints'
  addressPrefix: '10.100.1.0/24'
}]
param vnetPeSubnetName = 'snet-private-endpoints'
param privateDnsZoneName = 'privatelink.blob.core.windows.net'
