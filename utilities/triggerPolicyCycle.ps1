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
    Start-AzPolicyComplianceScan -AsJob
}