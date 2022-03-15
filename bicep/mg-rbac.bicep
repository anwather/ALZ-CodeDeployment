param rbacObjects array
param mgName string
targetScope = 'managementGroup'

resource rbac 'Microsoft.Authorization/roleAssignments@2019-04-01-preview' = [for item in rbacObjects: {
  name: guid('${mgName}-${item.principalId}-${item.roleDefinitionId}')
  properties: {
    principalType: item.principalType
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
  }
}]
