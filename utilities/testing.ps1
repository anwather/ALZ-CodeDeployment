[CmdletBinding()]
param ($TemplateFile)
BeforeAll {
    $ErrorActionPreference = 'Stop';
    Set-StrictMode -Version latest;
}
Describe 'Check options' {
    BeforeAll {
        $options = Get-Content -Path $TemplateFile -Raw | ConvertFrom-Json;
    }
    Context 'Option values' {
        BeforeDiscovery {
            $options = Get-Content -Path $TemplateFile -Raw | ConvertFrom-Json;
            $property = $options.PSObject.Properties | ForEach-Object { $_.Name }
        }
        It '<_> must have a value' -ForEach $property {
            $prop = $options.PSObject.Properties[$_];
            $prop.Value | Should -Not -BeNullOrEmpty;
        }
    }
}