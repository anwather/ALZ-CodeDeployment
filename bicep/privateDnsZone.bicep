param privateDnsZoneNames array

@batchSize(1)
resource dns 'Microsoft.Network/privateDnsZones@2020-01-01' = [for item in privateDnsZoneNames: {
  name: item
  location: 'global'
  properties: {}
}]
