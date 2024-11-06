# Testing

## Install Pester

``` powershell
Install-Module Pester -Force -Scope AllUsers
Import-Module Pester -Passthru
```

## Perform Tests with Code Coverage

``` powershell
.\test-module.ps1
```


# Upload Module to PowerShell Gallery
``` powershell
Publish-Module -Name .\brickBOX.psm1 -NuGetApiKey (Get-Secret 'powershellgallery' 'ApiKey' -AsPlainText)
```
