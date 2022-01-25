. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

foreach ($folder in Get-ChildItem -Path .\rbac -Directory -Recurse) {
    foreach ($file in Get-ChildItem $folder -File) {
        $ct = Get-Content $file -Raw | ConvertFrom-Json | ConvertPSObjectToHashtable
        $rbacObjects = @()

        $ct.rbac | Foreach-Object {
            $p = @{}
            $p = @{
                principalType = $_.principalType
            }
            if ($_.ContainsKey('groupName')) {
                $groupId = (Get-AzADGroup -DisplayName $_.groupName).Id
                $p.Add("principalId", $groupId)
            }
            if ($_.ContainsKey('groupId')) {
                $p.Add("principalId", $_.groupId)
            }

            if ($_.ContainsKey('userName')) {
                $userId = (Get-AzADUser -DisplayName $_.userName).Id
                $p.Add("principalId", $userId)
            }
            if ($_.ContainsKey('userId')) {
                $p.Add("principalId", $_.userId)
            }

            if ($_.ContainsKey('roleDefinitionName')) {
                $roleId = (Get-AzRoleDefinition -Name $_.roleDefinitionName).Id
                $p.Add("roleDefinitionId", $roleId)
            }

            if ($_.ContainsKey('roleDefinitionId')) {
                $p.Add("roleDefinitionId", $_.roleDefinitionId)
            }

            $rbacObjects += $p
        }

        $deploymentName = "$((Split-Path -Path $file.FullName).Split('/')[-1])-$($file.BaseName)"

        if ($folder.Name -match "^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$") {
            Select-AzSubscription -Subscription $folder.Name
            New-AzSubscriptionDeployment -Name $deploymentName `
                -Location $globals.defaultLocation `
                -TemplateFile .\bicep\sub-rbac.bicep `
                -rbacObjects $rbacObjects `
                -Verbose
        }
        else {
            New-AzManagementGroupDeployment -ManagementGroupId $folder.BaseName `
                -Name $deploymentName `
                -TemplateFile .\bicep\mg-rbac.bicep `
                -mgName $folder.BaseName `
                -rbacObjects $rbacObjects `
                -Location $globals.defaultLocation `
                -Verbose
        }
    }
}