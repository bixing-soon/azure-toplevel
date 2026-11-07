using '../main.bicep'

// ______________________________________________________
// Resource Group:

param location = 'australiaeast'
param rGroupNames = [
  'rg-tfstate' // 0: terraform storage account
  'rg-vnet' // 1: vnet
  'rg-email' // 2: email smtp server
  'rg-gpu_vm' // 3: gpu vm
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
param stAccPublicNetworkAccess = 'Enabled'

// ______________________________________________________
// Virtual Network:

param vnetName = 'vnet-toplevel'
param vnetAddressPrefix = '10.100.0.0/16'
param vnetSubnets = [{
  name: 'snet-pe'
  addressPrefix: '10.100.1.0/24'
}]
