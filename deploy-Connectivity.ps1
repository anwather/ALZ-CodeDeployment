. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

Select-AzSubscription -SubscriptionName $globals.connectivitySubscriptionId

$v = (Get-Content -Path ./globals.json | ConvertFrom-Json).connectivitySettings

$requiredValues = @("addressPrefix", "location", "dnsResourceGroup")

$requiredValues | ForEach-Object {
    if ($v.$_ -eq "") {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

$connectivityTemplateUri = "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/subscriptionTemplates/vwan-connectivity.json"

New-AzSubscriptionDeployment -TemplateUri $connectivityTemplateUri `
    -topLevelManagementGroupPrefix $globals.topLevelManagementGroupId `
    -addressPrefix $v.addressPrefix `
    -location $v.location `
    -enableHub $v.enableHub `
    -enableAzFw $v.enableAzFw `
    -firewallSku $v.firewallSku `
    -enableVpnGw $v.enableVpnGw `
    -enableErGW $v.enableErGw `
    -connectivitySubscription $globals.connectivitySubscriptionId `
    -vpnGatewayScaleUnit $v.vpnGatewayScaleUnit `
    -expressRouteScaleUnit $v.expressRouteScaleUnit `
    -Verbose

New-AzSubscriptionDeployment -Name "$($globals.topLevelManagementGroupId)-private-dns-rg" `
    -Location $v.location `
    -TemplateUri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/subscriptionTemplates/resourceGroup.json" `
    -rgName $v.dnsResourceGroup `
    -locationFromTemplate $v.location `
    -Verbose

$zoneupdate = @()

foreach ($zone in $v.dnsZones) {
    $zone = $zone -replace "location", $globals.defaultLocation
    $zoneupdate += $zone
}

New-AzResourceGroupDeployment -Name "$($globals.topLevelManagementGroupId)-private-dns" `
    -ResourceGroupName $v.dnsResourceGroup `
    -TemplateFile .\bicep\privateDnsZone.bicep `
    -privateDnsZoneNames $zoneupdate `
    -location "global" `
    -Verbose

