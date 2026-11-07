targetScope = 'subscription'

// ____________________________________________________________________________
// Resource Group:

@description('Location of all deployed resources.')
param location string

@description('Names of the resource groups to create. Index 0 hosts the storage accounts, index 1 hosts the VNet.')
@minLength(1)
param rGroupNames string[]

module rGroupModule './modules/resourceGroup.bicep' = [for name in rGroupNames: {
  name: '${name}-module'
  params: {
    rGroupName: name
    location: location
  }
}]

@description('Created resource group names.')
output resourceGroupNames array = [for (name, i) in rGroupNames: rGroupModule[i].outputs.rGroupName]

// ____________________________________________________________________________
// Storage Account (Terraform):

@description('Names of the storage accounts to create.')
param stAccNames string[]
param stAccSkuName string
param stAccKind string
param stAccAccessTier string
param stAccPublicNetworkAccess string

// scoped to terraform state resource group
module stAccModule './modules/storageAccount.bicep' = [for name in stAccNames: {
  name: '${name}-module'
  scope: resourceGroup(rGroupNames[0]) // do not change ordering of resource groups in main.bicepparam plz
  dependsOn: [
    rGroupModule
  ]
  params: {
    stAccName: name
    stAccSkuName: stAccSkuName
    stAccKind: stAccKind
    stAccAccessTier: stAccAccessTier
    stAccPublicNetworkAccess: stAccPublicNetworkAccess
  }
}]

@description('Created storage account names.')
output storageAccountNames array = [for (name, i) in stAccNames: stAccModule[i].outputs.stAccName]

// ____________________________________________________________________________
// Virtual Network:

param vnetName string
param vnetAddressPrefix string

@description('Subnets to create in the virtual network.')
param vnetSubnets {
  name: string
  addressPrefix: string
}[]

// scoped to rg-vnet
module vnetModule './modules/vnet.bicep' = {
  name: '${vnetName}-module'
  scope: resourceGroup(rGroupNames[1]) // do not change ordering of resource groups in main.bicepparam plz
  dependsOn: [
    rGroupModule
  ]
  params: {
    vnetName: vnetName
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    vnetSubnets: vnetSubnets
  }
}

@description('Virtual network ID.')
output vnetId string = vnetModule.outputs.vnetId
