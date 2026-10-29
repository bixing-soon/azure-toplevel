targetScope = 'subscription'

// ____________________________________________________________________________
// Resource Group:

@description('Location of all deployed resources.')
param location string

@description('Names of the resource groups to create. Index 0 hosts storage/endpoints, index 1 hosts the VNet.')
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
// Storage Account:

@description('Names of the storage accounts to create.')
param stAccNames string[]
param stAccSkuName string
param stAccKind string
param stAccAccessTier string

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

@description('Subnet that hosts the private endpoints. Must match an entry in vnetSubnets.')
param vnetPeSubnetName string

@description('Private DNS zone for the storage blob private endpoint.')
param privateDnsZoneName string

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
    privateDnsZoneName: privateDnsZoneName
  }
}

// endpoint for the bixingsttfstate storage account
module stAccPeModule './modules/privateEndpoint.bicep' = [for (name, i) in stAccNames: {
  name: '${name}-pe-module'
  scope: resourceGroup(rGroupNames[0]) // do not change ordering of resource groups in main.bicepparam plz
  params: {
    peName: 'pe-${name}-blob'
    location: location
    vnetSubnetId: '${vnetModule.outputs.vnetId}/subnets/${vnetPeSubnetName}'
    stAccId: stAccModule[i].outputs.stAccId
    privateDnsZoneId: vnetModule.outputs.privateDnsZoneId
  }
}]

@description('Virtual network ID.')
output vnetId string = vnetModule.outputs.vnetId
