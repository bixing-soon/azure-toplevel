param stAccName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param stAccSkuName string

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
])
param stAccKind string

@allowed([
  'Hot'
  'Cool'
  'Cold'
])
param stAccAccessTier string

@allowed([
  'Enabled'
  'Disabled'
])
param stAccPublicNetworkAccess string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: stAccName
  location: resourceGroup().location
  sku: {
    name: stAccSkuName
  }
  kind: stAccKind
  properties: {
    accessTier: stAccAccessTier
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        queue: {
          keyType: 'Service'
        }
        table: {
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Allow'
    }
    publicNetworkAccess: stAccPublicNetworkAccess
    supportsHttpsTrafficOnly: true
  }
}

output stAccName string = storageAccount.name
output stAccId string = storageAccount.id
