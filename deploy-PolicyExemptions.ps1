. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

$requiredValues = @("defaultLocation")

$requiredValues | ForEach-Object {
    if ($globals[$_] -eq "") {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

foreach ($folder in Get-ChildItem -Path .\policies\assignments -Directory -Recurse) {
    foreach ($file in Get-ChildItem $folder -File | Where-Object Name -Match "^EX_") {

        Write-Output "Deploying $($file.BaseName)"
        $deploymentName = "$((Split-Path -Path $file.FullName).Split('/')[-1])-$($file.BaseName)"
        if ($deploymentName.Length -ge 64) {
            Write-Output "Trimming the deployment name - $deploymentName"
            $deploymentName = $deploymentName -replace ".{25}$"
        }
        if ($folder.Name -match "^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$") {
            Select-AzSubscription -Subscription $folder.Name
            New-AzSubscriptionDeployment -Name $deploymentName `
                -Location $globals.defaultLocation `
                -TemplateFile .\policies\exemptions\exemption_template_subscription.json `
                -TemplateParameterFile $file.FullName `
                -Verbose
        }
        elseif ($folder.Name -match "^rg_") {
            $resourceGroupName = ($folder.Name -split "rg_")[1]
            $subscriptionName = ($folder.Parent).Split("/")[-1]
            Select-AzSubscription -Subscription $subscriptionName
            New-AzResourceGroupDeployment -Name $deploymentName `
                -ResourceGroupName $resourceGroupName `
                -TemplateFile .\policies\exemptions\exemption_template_resourcegroup.json `
                -TemplateParameterFile $file.FullName `
                -Verbose
        }
        else {
            New-AzManagementGroupDeployment -ManagementGroupId $folder.BaseName `
                -Name $deploymentName `
                -TemplateFile .\policies\exemptions\exemption_template_managementgroup.json `
                -TemplateParameterFile $file.FullName `
                -Location $globals.defaultLocation `
                -Verbose
        }
    }
    
}
