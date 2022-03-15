# Role Based Access Control Deployment

Very little RBAC is deployed using the CAF Enterprise Scale deployment. This is part of the Day 2 activities for Azure Landing Zones.

This document explains how to deploy RBAC at the subscription/management group scope.

## Requirements

- Todo

## File format

RBAC is deployed similar to Azure Policy in that the management group structure is replicated in a folder/file structure.

Each scope contains a file called ```rbac.json``` which is a json file consisting of an array of role assignments.

Roles are then deployed using the *deploy-RBAC* action.

### Required fields

|Field Name| Value | Notes
|---|---|---|
|principalType| group/user/serviceprincipal | Required
|servicePrincipalId| Object Id of Service Principal (Enterprise Application) | Not required if groupId or user Id is supplied
|groupName | Name of Azure AD Group | Not required if groupId is supplied
| groupId | Id of Azure AD Group | Not required if groupName is supplied
|userName | Name of Azure AD User | Not required if userId is supplied
| userId | Id of Azure AD User | Not required if userName is supplied
|roleDefinitionName | Name of the role | Not required if roleDefinitionId is supplied
|roleDefinitionId | Id of the role | Not required if roleDefinitionName is supplied

```
C:\SOURCE\CAF-MRT\RBAC
└───mrt
    ├───mrt-lzones
    │   └───mrt-corp
    │       ├───7397f5d2-c4bc-4696-91d6-3894f684ef38
    │       │       rbac.json << Assigned to the subscription>>
    │       │       
    │       └───cabc86b0-a6f1-4446-9071-cfa691484e89
    │               rbac.json << Assigned to the subscription>>
    │
    └───mrt-platform
        ├───mrt-connectivity
        │       rbac.json <<Assigned to the management group>>
        │       
        ├───mrt-identity
        └───mrt-management
```

Example RBAC File
```
{
    "rbac": [
        {
            "principalType": "group",
            "groupName": "Network Administrators",
            "roleDefinitionName": "Network Contributor"
        },
        {
            "principalType": "group",
            "groupId": "0e53d429-b721-4a98-a92b-e1d275935a7b",
            "roleDefinitionName": "Backup Contributor"
        },
        {
            "principalType": "user",
            "userName": "Demo User 1",
            "roleDefinitionName": "Contributor"
        }
    ]
}
```
