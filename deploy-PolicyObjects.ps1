. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

foreach ($definition in Get-ChildItem .\policies\definitions) {
    $ct = Get-Content $definition | ConvertFrom-Json
    New-AzManagementGroupDeployment -Name $definition.BaseName `
        -ManagementGroupId $globals.topLevelManagementGroupId `
        -TemplateFile .\bicep\definition.bicep `
        -policyName $definition.BaseName `
        -policyDefinition ($ct | ConvertPSObjectToHashtable) `
        -Location $globals.defaultLocation -Verbose -AsJob
}

foreach ($definition in Get-ChildItem .\policies\initiatives) {
    $ct = Get-Content $definition | ConvertFrom-Json
    New-AzManagementGroupDeployment -Name $definition.BaseName `
        -ManagementGroupId $globals.topLevelManagementGroupId `
        -TemplateFile .\bicep\setDefinition.bicep `
        -policyName $definition.BaseName `
        -policyDefinition ($ct | ConvertPSObjectToHashtable) `
        -Location $globals.defaultLocation -Verbose -AsJob
}