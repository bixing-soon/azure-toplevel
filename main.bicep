targetScope = 'subscription'

@description('Location of resource groups.')
@allowed([
  'australiaeast',
  'australiasoutheast',
  'australiacentral'
])
param location string


@description('Prefix for resource group names: rg-<prefix>-<environment>.')
@minLength(2)
@maxLength(40)
param prefix string

@description('Environments to create a resource group for.')
@minLength(1)
param environments array = [
  'dev'
]

@description('Region for the resource groups (metadata only).')
param location string = 'australiaeast'

@description('Tags applied to every resource group.')
param tags object = {}

resource resourceGroups 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for environment in environments: {
    name: 'rg-${prefix}-${environment}'
    location: location
    tags: union(tags, {
      environment: environment
      managedBy: 'bicep'
    })
  }
]

@description('Created resource group names.')
output resourceGroupNames array = [for (environment, i) in environments: resourceGroups[i].name]
