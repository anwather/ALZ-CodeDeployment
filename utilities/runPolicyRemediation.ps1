$subArray = @()

. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

Get-Content .\templates\mgStructure.json | ForEach-Object {
    if ($_ -match "[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}") {
        if ($_ -notmatch $globals.tenantId) {
            $subArray += $Matches[0]
        }
    }
}

$subArray | Foreach-Object {
    Select-Azsubscription $_
    $nonCompliantPolicies = Get-AzPolicyState | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" }
    foreach ($policy in $nonCompliantPolicies) {

        $remediationName = "rem." + $policy.PolicyDefinitionName
        if ($policy.PolicyDefinitionReferenceId -ne "") {
            Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -AsJob
        }
    }
}