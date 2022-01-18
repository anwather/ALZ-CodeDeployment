. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

Select-AzSubscription -SubscriptionName $globals.identitySubscriptionId

$v = (Get-Content -Path ./globals.json | ConvertFrom-Json).identitySettings

$identityTemplateUri = "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/subscriptionTemplates/vnetPeeringVwan.json"

New-AzSubscriptionDeployment -TemplateUri $identityTemplateUri `
    -Location $globals.defaultLocation `
    -vNetRgName $v.vNetRgName `
    -vNetName $v.vNetName `
    -vNetLocation $v.vNetLocation `
    -vNetCidrRange $v.vNetCidrRange `
    -vWanhubResourceId $v.vWanhubResourceId `
    -dnsServers $v.dnsServers `
    -Verbose