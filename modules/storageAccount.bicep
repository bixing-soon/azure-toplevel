param stAccName string
param stAccSkuName string = 'Standard_LRS'
param stAccKind string = 'StorageV2'
param stAccAccessTier string = 'Hot'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: stAccName
  location: resourceGroup().location
  sku: {
    name: stAccSkuName
  }
  kind: stAccKind
  properties: {
    accessTier: stAccAccessTier
    allowBlobPublicAccess: true
    allowCrossTenantReplication: true
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
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
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}

output stAccName string = storageAccount.name
