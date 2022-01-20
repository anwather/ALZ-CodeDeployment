. ./utilities/functions.ps1

$globals = Get-Content -Path ./globals.json | ConvertFrom-Json

$requiredValues = @("defaultLocation", "tenantId")

$requiredValues | ForEach-Object {
    if ($globals[$_] -eq "") {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

$v = Get-Content ./templates/mgStructure.json | ConvertFrom-Json

foreach ($tlManagementGroup in $v.($globals.tenantId)) {
    New-AzDeployment -Location $globals.defaultLocation -TemplateFile ./bicep/mg.bicep -Id $tlManagementGroup.id -DisplayName $tlManagementGroup.displayName -parent $globals.tenantId -Verbose
    if ($null -ne $tlManagementGroup.children) {
        foreach ($tlChild in $tlManagementGroup.children) {
            New-AzDeployment -Location $globals.defaultLocation -TemplateFile ./bicep/mg.bicep -Id $tlChild.id -DisplayName $tlChild.displayName -parent $tlManagementGroup.id -Verbose
            if ($null -ne $tlChild.children) {
                foreach ($tlSubChild in $tlChild.children) {
                    New-AzDeployment -Location $globals.defaultLocation -TemplateFile ./bicep/mg.bicep -Id $tlSubChild.id -DisplayName $tlSubChild.displayName -parent $tlChild.id -Verbose
                    if ($null -ne $tlSubChild.subscriptions) {
                        $tlSubchild.subscriptions | Foreach-Object {
                            New-AzDeployment -templatefile ./bicep/sub.bicep -Location $globals.defaultLocation -subscriptionId $_ -parent $tlSubChild.id -Verbose
                        }
                    }
                }
            }
        }
    }
}
