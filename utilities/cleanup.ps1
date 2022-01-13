#Set the management group prefix here
$prefix = "contoso"

# Remove all the custom policies
$mgs = Get-AzManagementGroup

$mgs | ForEach-Object { Get-AzPolicyAssignment -Scope $_.Id | Remove-AzPolicyAssignment }

Get-AzPolicySetDefinition -Custom -ManagementGroupName $prefix | Remove-AzPolicySetDefinition -Confirm:$false -Force -Verbose

Get-AzPolicyDefinition -Custom -ManagementGroupName $prefix | Remove-AzPolicyDefinition -Confirm:$false -Force -Verbose

# Remove all the resources deployed
Get-AzSubscription | Where-Object State -eq Enabled | ForEach-Object { Select-AzSubscription $_.Id; Get-AzResourceGroup | Remove-AzResourceGroup -Force -AsJob }

# Move all the subs to the root management group
$targetManagementGroup = (Get-AzSubscription | Select-Object -First 1).TenantId

Get-AzSubscription | Where-Object State -eq Enabled | ForEach-Object {
    New-AzManagementGroupSubscription -SubscriptionId $_.Id -GroupName $targetManagementGroup
}

# Remove all the management groups - run this until they are all gone - note it doesn't check for other MG's so dont run in customer environment
Get-AzManagementGroup | Where-Object Name -ne $targetManagementGroup | ForEach-Object {
    Remove-AzManagementGroup -GroupName $_.Name -ErrorAction Continue
}

# Remove Microsoft Defender for Cloud plans
Get-AzSubscription | Where-Object State -eq Enabled | ForEach-Object { 
    Select-AzSubscription $_.Id
    Get-AzSecurityPricing | ForEach-Object -Parallel {
        if ($_.PricingTier -ne "Free") {
            Set-AzSecurityPricing -Name $_.Name -PricingTier Free
        }
    }
}

