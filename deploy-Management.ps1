. ./utilities/functions.ps1

$globals = Get-Content -Path ./globals.json | ConvertFrom-Json

if ($null -eq $globals.managementSubscriptionId) {
    Write-Error "Add Management subscription Id to global variables before running"
    exit
}

Select-AzSubscription -SubscriptionName $globals.managementSubscriptionId

$v = (Get-Content -Path ./globals.json | ConvertFrom-Json).managementSettings

$requiredValues = @("managementResourceGroupName", "logAnalyticsWorkspaceName", "automationAccountName", "deploySentinel")

$requiredValues | ForEach-Object {
    if ($null -eq $v[$_]) {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

New-AzSubscriptionDeployment -Name "management-la" `
    -Location $globals.defaultLocation `
    -TemplateUri 'https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/subscriptionTemplates/logAnalyticsWorkspace.json' `
    -rgName $v.managementResourceGroupName `
    -workspaceName $v.logAnalyticsWorkspaceName `
    -workspaceRegion $globals.defaultLocation `
    -retentionInDays "30" `
    -automationAccountName $v.automationAccountName `
    -automationRegion $globals.defaultLocation `
    -Verbose

New-AzSubscriptionDeployment -Name "management-la-solution" `
    -Location $globals.defaultLocation `
    -TemplateUri 'https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/subscriptionTemplates/logAnalyticsSolutions.json' `
    -rgName $v.managementResourceGroupName `
    -workspaceName $v.logAnalyticsWorkspaceName `
    -workspaceRegion $globals.defaultLocation `
    -enableSecuritySolution $v.deploySentinel `
    -Verbose