targetScope = 'subscription'

@description('Location of the resource groups.')
@allowed([
  'australiaeast'
  'australiasoutheast'
  'australiacentral'
])
param rGroupLocation string = 'australiaeast'

@description('Names of the resource groups to create.')
@minLength(1)
param rGroupNames string[]

@description('Names of the storage accounts to create.')
param stAccNames string[]
param stAccSkuName string = 'Standard_LRS'
param stAccKind string = 'StorageV2'
param stAccAccessTier string = 'Hot'

module rGroupModule './modules/resourceGroup.bicep' = [for name in rGroupNames: {
  name: '${name}-module'
  params: {
    rGroupName: name
    rGroupLocation: rGroupLocation
  }
}]

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

@description('Created resource group names.')
output resourceGroupNames array = [for (name, i) in rGroupNames: rGroupModule[i].outputs.rGroupName]

@description('Created storage account names.')
output storageAccountNames array = [for (name, i) in stAccNames: stAccModule[i].outputs.stAccName]
