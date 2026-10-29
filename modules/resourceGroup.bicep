targetScope = 'subscription'

param rGroupName string
param rGroupLocation string = 'australiaeast'

resource rGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rGroupName
  location: rGroupLocation
}

output rGroupName string = rGroup.name
