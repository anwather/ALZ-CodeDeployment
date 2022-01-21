# Custom Policy Deployment

The basic steps deploy the policies included in the default CAF Enterprise Scale repository. 

This document explains how to deploy custom policy definitions, initiatives and assignments. 

## Requirements

- Todo

### Example 1 - Tagging Policies in an Initiative

Background: Contoso requires that each resource group contains the following tags - CostCentre, EnvironmentType. These are scoped to each landing zone subscription.

Steps:-
1. Identify any built-in policies which can be used.
- Add or replace a tag on subscriptions - /providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1
- Add or replace a tag on resource groups - /providers/Microsoft.Authorization/policyDefinitions/d157c373-a6c4-483d-aaad-570756956268

Since this uses built-in policies there is no need to create a custom definition.

2. Create the initiative definition which will be used.
- Use one of the sample definitions to copy - or create it manually in the portal and export it.

Use the code below to grab a JSON representation of the manually created initiative and then remove any details not required.

```
(Get-AzPolicySetDefinition -Id  "your initiative Id").Properties | ConvertTo-Json -Depth 10 | Out-File "save to initiative folder .json"
```
For the example above this was the policy extracted and copied to *.\policies\initiatives\Deploy-SubAndRGTags.json*

```
{
  "Description": "Contains the policies to enforce subscription and resource group tagging. ",
  "DisplayName": "Subscription and Resource Group Tagging",
  "Metadata": {
    "category": "Tags"
  },
  "Parameters": {
    "Tag1Name": {
      "type": "string",
      "metadata": {
        "displayName": "Tag 1 Name",
        "description": "The first enforced tag name"
      }
    },
    "Tag2Name": {
      "type": "string",
      "metadata": {
        "displayName": "Tag 2 Name",
        "description": "The second enforced tag name"
      }
    },
    "Tag1Value": {
      "type": "string",
      "metadata": {
        "displayName": "Tag 1 Value",
        "description": "The first enforced tag value"
      }
    },
    "Tag2Value": {
      "type": "string",
      "metadata": {
        "displayName": "Tag 2 Value",
        "description": "The second enforced tag value"
      }
    }
  },
  "PolicyDefinitionGroups": [],
  "PolicyDefinitions": [
    {
      "policyDefinitionReferenceId": "SubscriptionTag1",
      "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1",
      "parameters": {
        "tagName": {
          "value": "[parameters('Tag1Name')]"
        },
        "tagValue": {
          "value": "[parameters('Tag1Value')]"
        }
      },
      "groupNames": []
    },
    {
      "policyDefinitionReferenceId": "SubscriptionTag2",
      "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1",
      "parameters": {
        "tagName": {
          "value": "[parameters('Tag2Name')]"
        },
        "tagValue": {
          "value": "[parameters('Tag2Value')]"
        }
      },
      "groupNames": []
    },
    {
      "policyDefinitionReferenceId": "ResourceGroupTag1",
      "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/d157c373-a6c4-483d-aaad-570756956268",
      "parameters": {
        "tagName": {
          "value": "[parameters('Tag1Name')]"
        },
        "tagValue": {
          "value": "[parameters('Tag1Value')]"
        }
      },
      "groupNames": []
    },
    {
      "policyDefinitionReferenceId": "ResourceGroupTag2",
      "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/d157c373-a6c4-483d-aaad-570756956268",
      "parameters": {
        "tagName": {
          "value": "[parameters('Tag2Name')]"
        },
        "tagValue": {
          "value": "[parameters('Tag2Value')]"
        }
      },
      "groupNames": []
    }
  ]
}
```
3. Deploy the initiative using the *deploy-PolicyObjects* action. 

4. Create an assignment definition file.
- The example above is going to be deployed at the subscription level
- The policies make use of a managed identity so will need to do RBAC as well

Again copy or create manually the assignment for the policy initiative. Place the file in the *policies\assignmentDefinitions* folder.

Be careful to ensure the parameters flow correctly and there are role assignment resources for each role in the initative. 

For the example above this is the assignment definition created

```
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "tag1Name": {
            "type": "string"
        },
        "tag1Value": {
            "type": "string"
        },
        "tag2Name": {
            "type": "string"
        },
        "tag2Value": {
            "type": "string"
        },
        "enforcementMode": {
            "type": "string",
            "allowedValues": [
                "Default",
                "DoNotEnforce"
            ],
            "defaultValue": "Default"
        }
    },
    "variables": {
        "policyDefinitions": {
            "deployTags": "/providers/Microsoft.Management/managementGroups/mrt/providers/Microsoft.Authorization/policySetDefinitions/Deploy-SubAndRGTags"
        },
        "policyAssignmentNames": {
            "deployTags": "DeploySubRGTagging",
            "description": "Deploy required tags to subscription and resource groups",
            "displayName": "Deploy required tags to subscription and resource groups"
        },
        "roleAssignments": [
            "4a9ae827-6dc8-4573-8ac7-8239d42aa03f",
            "b24988ac-6180-42a0-ab88-20f7382dd24c"
        ],
        "roleAssignmentNames": [
            "[guid(concat(deployment().name,variables('roleAssignments')[0]))]",
            "[guid(concat(deployment().name,variables('roleAssignments')[1]))]"
        ]
    },
    "resources": [
        {
            "type": "Microsoft.Authorization/policyAssignments",
            "apiVersion": "2021-06-01",
            "name": "[variables('policyAssignmentNames').deployTags]",
            "location": "[deployment().location]",
            "identity": {
                "type": "SystemAssigned"
            },
            "properties": {
                "scope": "[subscription().id]",
                "description": "[variables('policyAssignmentNames').description]",
                "displayName": "[variables('policyAssignmentNames').displayName]",
                "policyDefinitionId": "[variables('policyDefinitions').deployTags]",
                "enforcementMode": "[parameters('enforcementMode')]",
                "parameters": {
                    "Tag1Name": {
                        "value": "[parameters('tag1Name')]"
                    },
                    "Tag1Value": {
                        "value": "[parameters('tag1Value')]"
                    },
                    "Tag2Name": {
                        "value": "[parameters('tag2Name')]"
                    },
                    "Tag2Value": {
                        "value": "[parameters('tag2Value')]"
                    }
                }
            }
        },
        {
            "type": "Microsoft.Authorization/roleAssignments",
            "apiVersion": "2019-04-01-preview",
            "name": "[variables('roleAssignmentNames')[copyIndex()]]",
            "copy": {
                "name": "rbac",
                "count": "[length(variables('roleAssignmentNames'))]"
            },
            "dependsOn": [
                "[resourceId('Microsoft.Authorization/policyAssignments', variables('policyAssignmentNames').deployTags)]"
            ],
            "properties": {
                "principalType": "ServicePrincipal",
                "roleDefinitionId": "[concat('/providers/Microsoft.Authorization/roleDefinitions/', variables('roleAssignments')[copyIndex()])]",
                "principalId": "[toLower(reference(concat('/providers/Microsoft.Authorization/policyAssignments/', variables('policyAssignmentNames').deployTags), '2019-09-01', 'Full' ).identity.principalId)]"
            }
        }
    ],
    "outputs": {}
}
```
5. Create the assignment definition parameter file.
- This file can easily be done by using the VS Code ARM Tools extension and creating a parameter file from the assignment definition file.
- To deploy the a subscription you should create a folder in the assignments folder under the management group where the subscription is and give it the same name as the subscription id.

e.g.
```
C:.
├───.github
│   └───workflows
├───bicep
├───policies
│   ├───assignmentDefinitions
│   ├───assignments
│   │   └───mrt
│   │       ├───mrt-lzones
│   │       │   └───mrt-corp
│   │       │       └───cabc86b0-a6f1-4446-9071-cfa691484e89 <<This is the folder created for subscription level deployments - the parameter file goes here>>
│   │       └───mrt-platform
│   │           ├───mrt-identity
│   │           └───mrt-management
│   ├───definitions
│   └───initiatives
├───templates
└───utilities
```
For the parameter file which fits the example see below:

```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "tag1Name": {
            "value": "CostCenter"
        },
        "tag1Value": {
            "value": "000001"
        },
        "tag2Name": {
            "value": "EnvironmentType"
        },
        "tag2Value": {
            "value": "Production"
        },
        "enforcementMode": {
            "value": "Default"
        }
    }
}
```
6. Run the *deploy-PolicyAssignment* action and deploy the assignment and roles.

### Example 2 - Deploy single policy - no initiative

Background: Contoso requires that resource are deployed only into the australiaeast and australiasoutheast regions for all landing zones.

Steps:-

1. Identify any built-in policies which can be used.
- Allowed locations - /providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c

Since this uses built-in policies there is no need to create a custom definition.

2. No initiative is being used so only an assignment definition needs to be created. 

```
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "listOfAllowedLocations": {
            "type": "Array",
            "metadata": {
                "description": "The list of locations that can be specified when deploying resources.",
                "strongType": "location",
                "displayName": "Allowed locations"
            }
        }
    },
    "functions": [],
    "variables": {
        "policyDefinitions": {
            "allowedLocations": "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
        }
    },
    "resources": [
        {
            "type": "Microsoft.Authorization/policyassignments",
            "apiVersion": "2021-06-01",
            "name": "DENY-NotAllowedLocations",
            "location": "[deployment().location]",
            "properties": {
                "description": "Denies the creation of resources not in the allowed locations",
                "displayName": "Enforce allowed locations",
                "policyDefinitionId": "[variables('policyDefinitions').allowedLocations]",
                "parameters": {
                    "listOfAllowedLocations": {
                        "value": "[parameters('listOfAllowedLocations')]"
                    }
                }

            }
        }
    ],
    "outputs": {}
}
```

3. Create the parameter file - this time at the landing zone corporate management group scope.

```
C:.
├───.github
│   └───workflows
├───bicep
├───policies
│   ├───assignmentDefinitions
│   ├───assignments
│   │   └───mrt
│   │       ├───mrt-lzones
│   │       │   └───mrt-corp <<Create the parameter file here>>
│   │       │       └───cabc86b0-a6f1-4446-9071-cfa691484e89
│   │       └───mrt-platform
│   │           ├───mrt-identity
│   │           └───mrt-management
│   ├───definitions
│   └───initiatives
├───templates
└───utilities
```

The file is below:
```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "listOfAllowedLocations": {
            "value": [
                "australiaeast",
                "australiasoutheast"
            ]
        }
    }
}
```
4. Run the *deploy-PolicyAssignment* action and deploy the assignment and roles.



