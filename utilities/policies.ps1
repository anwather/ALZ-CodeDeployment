$globals = Get-Content -Path ./globals.json | ConvertFrom-Json

$v = Get-Content .\templates\mgStructure.json | ConvertFrom-Json

New-Item .\policies\definitions -ItemType Directory -Force
New-Item .\policies\initiatives -ItemType Directory -Force

$defaultPolicyURIs = @(
    'https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/managementGroupTemplates/policyDefinitions/policies.json'
)

foreach ($policyUri in $defaultPolicyURIs) {
    $rawContent = (Invoke-WebRequest -Uri $policyUri).Content | ConvertFrom-Json
    $rawContent.variables[0].policies.policyDefinitions | Foreach-Object {
        $_.properties | ConvertTo-Json -Depth 50 | Out-File -FilePath .\policies\definitions\$($_.Name).json -Force
        (Get-Content .\policies\definitions\$($_.Name).json) -replace "\[\[", "[" | Set-Content .\policies\definitions\$($_.Name).json
    }
    $rawContent.variables[0].initiatives.policySetDefinitions | Foreach-Object {
        $_.properties | ConvertTo-Json -Depth 50 | Out-File -FilePath .\policies\initiatives\$($_.Name).json -Force
        (Get-Content .\policies\initiatives\$($_.Name).json) -replace "\[\[", "[" | Set-Content .\policies\initiatives\$($_.Name).json
        (Get-Content .\policies\initiatives\$($_.Name).json) -replace "variables\('scope'\)", "'/providers/Microsoft.Management/managementGroups/$($v.($globals.tenantId).id)'" | Set-Content .\policies\initiatives\$($_.Name).json
        (Get-Content .\policies\initiatives\$($_.Name).json) -replace "', '", "" | Set-Content .\policies\initiatives\$($_.Name).json
        (Get-Content .\policies\initiatives\$($_.Name).json) -replace "\[concat\(('(.+)')\)\]", "`$2" | Set-Content .\policies\initiatives\$($_.Name).json
    }
}

$additionalPolicyURIs = @(
    'https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/managementGroupTemplates/policyDefinitions/DENY-PublicEndpointsPolicySetDefinition.json',
    'https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/managementGroupTemplates/policyDefinitions/DINE-PrivateDNSZonesPolicySetDefinition.json'
)

foreach ($policyUri in $additionalPolicyURIs) {
    $rawContent = (Invoke-WebRequest -Uri $policyUri).Content | ConvertFrom-Json
    $rawContent.resources | Foreach-Object {
        $_.properties | ConvertTo-Json -Depth 50 | Out-File -FilePath .\policies\initiatives\$($_.Name).json -Force
        (Get-Content .\policies\initiatives\$($_.Name).json) -replace "\[\[", "[" | Set-Content .\policies\initiatives\$($_.Name).json
        (Get-Content .\policies\initiatives\$($_.Name).json) -replace "variables\('scope'\)", "'/providers/Microsoft.Management/managementGroups/$($v.($globals.tenantId).id)'" | Set-Content .\policies\initiatives\$($_.Name).json
    }
}

git clone --depth 1 https://github.com/Azure/Enterprise-Scale.git tmp 

foreach ($file in Get-ChildItem .\tmp\eslzArm\managementGroupTemplates\policyAssignments -File) {
    Copy-Item $file -Destination .\policies\assignmentDefinitions -Force
}

Start-Sleep -Seconds 15

Remove-Item tmp -Recurse -Force