. .\utilities\functions.ps1

$globals = Get-Content -Path .\globals.json | ConvertFrom-Json

if ($globals.identitySubscriptionId -eq "") {
    Write-Error "Add Management subscription Id to global variables before running"
    exit
}

Select-AzSubscription -SubscriptionName $globals.identitySubscriptionId

$v = (Get-Content -Path ./globals.json | ConvertFrom-Json).identitySettings

$requiredValues = @("vNetRgName", "vNetName", "vNetLocation", "vNetCidrRange", "vWanhubResourceId")

$requiredValues | ForEach-Object {
    if ($v.$_ -eq "") {
        Write-Error "$_ contains no value in globals.json"
        exit
    }
}

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