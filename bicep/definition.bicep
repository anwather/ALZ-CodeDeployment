targetScope = 'managementGroup'
param policyDefinitions array

resource policyName_resource 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for item in policyDefinitions: {
  name: item.Name
  properties: item.Definition
}]
