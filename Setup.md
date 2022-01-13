# Setup files for deployment

1. Fill in values in ```globals.json```
2. Fill in values in ```templates``` folder if they are available - some won't be until you deploy various sections
3. Add extra management groups and subscriptions to ```templates\mgStructure.json```
4. Run ```utilities\policies.ps1``` to download and populate ```assignments```,```initiatives```,```assignmentDefinitions``` folders.
5. Verify the structure in the ```policies\assignments``` matches the ```mgStructure.json``` file
6. Check values for parameters in policy assignments -  not all values will be available

managementGroupStructure
PolicyObjects
Management
PolicyAssignments
Connectivity
Identity