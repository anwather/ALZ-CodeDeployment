. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

$assignmentDefinitions = Get-ChildItem .\policies\assignmentDefinitions -File

foreach ($folder in Get-ChildItem -Path .\policies\assignments -Directory -Recurse) {
    foreach ($file in Get-ChildItem $folder -File) {
        Write-Output "Deploying $($file.BaseName)"
        New-AzManagementGroupDeployment -ManagementGroupId $folder.BaseName `
            -TemplateFile ($assignmentDefinitions | Where-Object Name -match $file.Name).FullName `
            -TemplateParameterFile $file.FullName `
            -Location $globals.defaultLocation `
            -Verbose -AsJob
    }
}