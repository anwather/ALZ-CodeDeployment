. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

$requiredValues = @("defaultLocation")

$requiredValues | ForEach-Object {
    if ($null -eq $v[$_]) {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

$assignmentDefinitions = Get-ChildItem .\policies\assignmentDefinitions -File

foreach ($folder in Get-ChildItem -Path .\policies\assignments -Directory -Recurse) {
    foreach ($file in Get-ChildItem $folder -File) {
        $ct = (Get-Content $file.FullName -Raw | ConvertFrom-Json).Parameters | ConvertPSObjectToHashtable

        $ct.GetEnumerator() | Foreach-Object {
            if ($_.value.value -eq "") {
                Write-Error "The file $($file.FullName) contains no value for the parameter $($_.Name)"
            }
        }

        Write-Output "Deploying $($file.BaseName)"
        New-AzManagementGroupDeployment -ManagementGroupId $folder.BaseName `
            -TemplateFile ($assignmentDefinitions | Where-Object Name -match $file.Name).FullName `
            -TemplateParameterFile $file.FullName `
            -Location $globals.defaultLocation `
            -Verbose -AsJob
    }
}