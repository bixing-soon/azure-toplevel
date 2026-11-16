targetScope = 'subscription'

@description('Location of all deployed resources.')
param location string

@description('Resource group that hosts the Terraform state storage account.')
param rGroupName string

module rGroupModule './modules/resourceGroup.bicep' = {
  name: '${rGroupName}-module'
  params: {
    rGroupName: rGroupName
    location: location
  }
}

@description('Created resource group name.')
output resourceGroupName string = rGroupModule.outputs.rGroupName

@description('Storage account names. 3-24 chars, lowercase letters and digits only, globally unique.')
param stAccNames string[]
param stAccSkuName string
param stAccKind string
param stAccAccessTier string
param stAccPublicNetworkAccess string

module stAccModule './modules/storageAccount.bicep' = [for name in stAccNames: {
  name: '${name}-module'
  scope: resourceGroup(rGroupName)
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
