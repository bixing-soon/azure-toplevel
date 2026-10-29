using '../main.bicep'

// ______________________________________________________
// Resource Group:

param location = 'australiaeast'
param rGroupNames = [
  'rg-tfstate' // 0: storage acc + private endpoints
  'rg-vnet' // 1: vnet + private DNS zone
  'rg-vpn' // 2: vm with tailscale in it
  'rg-email' // 3: email smtp server
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
param vnetSubnets = [{ // DO NOT DISPLACE THE ORDER
  name: 'snet-pe'
  addressPrefix: '10.100.1.0/24'
}]
param privateDnsZoneName = 'privatelink.blob.core.windows.net'
// must be that URL cuz its the only valid one
