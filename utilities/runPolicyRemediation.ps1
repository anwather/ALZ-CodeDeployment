Get-AzSubscription | Where-Object state -eq "Enabled" | Foreach-Object {
    Select-Azsubscription $_
    $nonCompliantPolicies = Get-AzPolicyState | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" }
    foreach ($policy in $nonCompliantPolicies) {

        $remediationName = "rem." + $policy.PolicyDefinitionName
        if ($policy.PolicyDefinitionReferenceId -ne "") {
            Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -AsJob
        }
    }
}
