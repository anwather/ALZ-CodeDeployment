param rbacObjects array
targetScope = 'subscription'

resource rbac 'Microsoft.Authorization/roleAssignments@2019-04-01-preview' = [for item in rbacObjects: {
  name: guid('${subscription().id}-${item.principalId}-${item.roleDefinitionId}')
  properties: {
    principalType: item.principalType
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
  }
}]
