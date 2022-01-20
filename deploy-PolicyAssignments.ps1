. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

$requiredValues = @("defaultLocation")

$requiredValues | ForEach-Object {
    if ($globals[$_] -eq "") {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

$assignmentDefinitions = Get-ChildItem .\policies\assignmentDefinitions -File

foreach ($folder in Get-ChildItem -Path .\policies\assignments -Directory -Recurse) {
    foreach ($file in Get-ChildItem $folder -File) {
        $ct = (Get-Content $file.FullName -Raw | ConvertFrom-Json).Parameters | ConvertPSObjectToHashtable
        $chk = $true
        $ct.GetEnumerator() | Foreach-Object {
            if ($_.value.value -eq "") {
                Write-Error "The file $($file.FullName) contains no value for the parameter $($_.Name)"
                $chk = $false
            }
        }

        if ($chk -eq $true) {
            Write-Output "Deploying $($file.BaseName)"
            $deploymentName = "$((Split-Path -Path $file.FullName).Split('\')[-1])-$($file.BaseName)"
            if ($deploymentName.Length -ge 64) {
                Write-Output "Trimming the deployment name - $deploymentName"
                $deploymentName = $deploymentName -replace ".{25}$"
            }
            New-AzManagementGroupDeployment -ManagementGroupId $folder.BaseName `
                -Name $deploymentName `
                -TemplateFile ($assignmentDefinitions | Where-Object Name -match $file.Name).FullName `
                -TemplateParameterFile $file.FullName `
                -Location $globals.defaultLocation `
                -Verbose
        }
        else {
            Write-Error "Could not deploy $($file.BaseName)"
        }
    }
}
