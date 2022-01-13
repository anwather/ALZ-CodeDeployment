targetScope = 'managementGroup'
param policyName string
param policyDefinition object

resource policyName_resource 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: policyDefinition
}