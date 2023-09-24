# ps-bricks

A collection of powershell functions, put in a module to make scripting easier

## Installation

``` powershell
#download Module
$modulePath = Join-Path ($Env:PSModulePath.Split(';') -like "$($env:USERPROFILE)*PowerShell\Modules")[0] 'ps-bricks'
if (Test-Path $modulePath) { New-Item $modulePath -ItemType Directory | Out-Null }
Invoke-WebRequest 'https://raw.githubusercontent.com/pagebox/ps-bricks/main/ps-bricks.psm1' -OutFile (Join-Path $modulePath 'ps-bricks.psm1')
Invoke-WebRequest 'https://raw.githubusercontent.com/pagebox/ps-bricks/main/ps-bricks.psd1' -OutFile (Join-Path $modulePath 'ps-bricks.psd1')

#load Module
Import-Module ps-bricks -Force
Get-Module ps-bricks | fl
```

## Functions

**Start-Elevated** Executes a PowerShell script or command with elevated rights  
**Get-Secret** Reads and saves secure strings to hkcu in a secure way.  
**Set-IniContent** Add or Update key-value pairs in ini-files  


## Testing

### Install Pester

``` powershell
Install-Module Pester -Force
Import-Module Pester -Passthru
```

### Perform Tests

``` powershell
Invoke-Pester -Output Detailed .\tests\ps-bricks.Tests.ps1 
```
