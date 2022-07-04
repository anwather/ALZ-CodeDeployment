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
    foreach ($file in Get-ChildItem $folder -File | Where-Object Name -NotMatch "^EX_") {
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
            if ($IsWindows) {
                $deploymentName = "$((Split-Path -Path $file.FullName).Split('\')[-1])-$($file.BaseName)"
            }
            else {
                $deploymentName = "$((Split-Path -Path $file.FullName).Split('/')[-1])-$($file.BaseName)"
            }
            
            if ($deploymentName.Length -ge 64) {
                Write-Output "Trimming the deployment name - $deploymentName"
                $deploymentName = $deploymentName -replace ".{25}$"
            }
            if ($folder.Name -match "^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$") {
                Select-AzSubscription -Subscription $folder.Name
                New-AzSubscriptionDeployment -Name $deploymentName `
                    -Location $globals.defaultLocation `
                    -TemplateFile ($assignmentDefinitions | Where-Object BaseName -match $file.BaseName).FullName `
                    -TemplateParameterFile $file.FullName `
                    -Verbose
            }
            else {
                New-AzManagementGroupDeployment -ManagementGroupId $folder.BaseName `
                    -Name $deploymentName `
                    -TemplateFile ($assignmentDefinitions | Where-Object BaseName -match $file.BaseName) `
                    -TemplateParameterFile $file.FullName `
                    -Location $globals.defaultLocation `
                    -Verbose
            }
        }
        else {
            Write-Error "Could not deploy $($file.BaseName)"
        }
    }
}
