. ./utilities/functions.ps1

$globals = Get-Content -Path ./globals.json | ConvertFrom-Json

$policyArray = @()

foreach ($definition in Get-ChildItem ./policies/definitions) {
    $p = @{
        Name       = $definition.BaseName
        Definition = Get-Content $definition | ConvertFrom-Json | ConvertPSObjectToHashtable
    }
    $policyArray += $p
}

New-AzManagementGroupDeployment -Name 'deploy-policies' `
    -ManagementGroupId $globals.topLevelManagementGroupId `
    -TemplateFile ./bicep/definition.bicep `
    -policyDefinitions $policyArray `
    -Location $globals.defaultLocation -Verbose

$policyArray = @()

foreach ($definition in Get-ChildItem ./policies/initiatives) {
    $p = @{
        Name       = $definition.BaseName
        Definition = Get-Content $definition | ConvertFrom-Json | ConvertPSObjectToHashtable
    }
    $policyArray += $p
}

New-AzManagementGroupDeployment -Name 'deploy-initiatives' `
    -ManagementGroupId $globals.topLevelManagementGroupId `
    -TemplateFile ./bicep/setDefinition.bicep `
    -policyDefinitions $policyArray `
    -Location $globals.defaultLocation -Verbose