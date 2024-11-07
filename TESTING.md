# Testing & Publishing

## Install Pester

``` powershell
Install-Module Pester -Force -Scope AllUsers
Import-Module Pester -Passthru
```

## Perform Tests with Code Coverage

``` powershell
.\test-module.ps1
```

## Publishing preparation

- copy the function-markdown-table to `README.md`
- update `brickBOX.psd1`
  - update `ModuleVersion`
  - update `FunctionsToExport`
- complete pull request
- Upload Module to PowerShell Gallery


## Upload Module to PowerShell Gallery
``` powershell
Publish-Module -Name .\brickBOX.psm1 -NuGetApiKey (Get-Secret 'powershellgallery' 'ApiKey' -AsPlainText)
```
