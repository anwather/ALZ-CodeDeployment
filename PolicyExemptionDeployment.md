# Policy Exemption Deployment

## Creating the exemption

1. Decide on the scope of the exemption
2. Use the appropriate template in ```.\policies\exemptions``` to generate a parameter file
3. The file should be named ```EX_<<exemptionname>>.json```
4. Place the file in the ```.\policies\assignments``` directory at the deployment scope. If resource group deployment is required create a folder under the subscription in the structure and name it ```rg_<<resource group name>>```. The pipeline will determine the resource group name and subscription and deploy at the correct scope.
5. Run the ```deploy-PolicyExemptions``` pipeline. 