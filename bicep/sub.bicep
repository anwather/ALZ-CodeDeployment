param subscriptionId string
param parent string

resource mgp 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: parent
  scope: tenant()
}

resource sub 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = {
  name: subscriptionId
  parent: mgp
}
