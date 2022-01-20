# CAF Code Deployment

This project helps to deploy and manage the Azure Landing Zones platform deployment using Infrastrcture as Code.

It provides a simple method of deployment and management to suit teams which are new to IaC concepts.

## Deployed Artifacts

Drawing on the templates and values from the [Enterprise-Scale](https://github.com/Azure/Enterprise-Scale) repository it should provide a like for like deployment to the portal experiance however allows for further customisation and manageability.

The following objects can be deployed:
- Management group and subscription structure
- Azure Policy definitions, set definitions and assignments
- Management subscription including Log Analytics and Automation Account
- Connectivity subscription utilising VWAN
- Identity subscription peered to the central hub

## Initial Setup

1. Create a new repository using the **Use this template** button in GitHub
2. Clone to a local machine
3. Add values to the *globals.json* file. Some of these values won't be available yet and not all are required by each workflow. To deploy the management group structure you need at least the following
    - tenantId
    - defaultLocation
    - topLevelManagementGroupPrefix
4. Add required values to the *\templates\mgStructure.json* file. Fill in the tenant Id and top level management group details where indicated.
5. The management group structure is the same as deployed via the portal experiance, you can add management groups or add subscriptions to the management groups by entering the subscription Id in the ```subscriptions``` key.

e.g.
```
{
    "id": "management",
    "displayName": "Management",
    "subscriptions": [
        "5fbff64b-5bbc-4190-84d0-37225536885d"
    ]
}
```
6. Run the *utilities\policies.ps1* file to download the existing policy definitions, set definitions and assignment from the [Enterprise-Scale](https://github.com/Azure/Enterprise-Scale) repository. This utility can be run periodically to check for policy changes published upstream.
7. Update the folder structure in the *policies\assignments* folder to match the management group structure. The scripts use this folder structure to correlate the Ids for the management groups so you will have to rename the folders to match this structure. Policy assignments provided in the portal deployment are already created so review them before deploying. Some of the definitions will required updating before deploying to add values such as a Log Analytics workspace resource Id. 

## Secret Configuration in GitHub

Create a new service principal and assign it as an owner at the Root Management Group.

Add the service principal values to secrets in the GitHub repository as below. These values are used to connect to Azure and deploy resources.

|Secret Name| Value|
|---|---|
|ARM_CLIENT_ID | SPN Application Id|
|ARM_CLIENT_SECRET |  SPN Secret|
|ARM_SUBSCRIPTION_ID  | Default subscription Id |
|ARM_TENANT_ID  | Tenant Id |

## Deploy the Management Group Structure

GitHub Actions are provided to deploy each phase of the Azure Landing Zone.

Run the *deploy-ManagementGroups* action to deploy the mamagement group structure.

## Deploy Policy Objects

Run the *deploy-PolicyObjects* action to deploy the policy definitions and set definitions.

## Deploy Management Subscription

Before deploying the management subscription ensure the following tasks have been completed.
1. The management subscription Id has been placed in the *templates\mgStructure.json* file and has been deployed
2. The management subscription Id has been added to the value ```managementSubscriptionId``` in *globals.json*
3. All values are present in *globals.json* under the ```managementSettings``` value.

## Deploy Policy Assignments

## Deploy Connectivity Subscription

## Deploy Identity Subscription
