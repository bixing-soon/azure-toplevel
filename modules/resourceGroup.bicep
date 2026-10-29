targetScope = 'subscription'

param rGroupName string

@allowed([
  'australiaeast'
  'australiasoutheast'
  'australiacentral'
])
param location string

resource rGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rGroupName
  location: location
}

output rGroupName string = rGroup.name
