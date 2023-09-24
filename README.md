# brickBOX

A collection of powershell functions, put in a module to make scripting easier

## Installation

``` powershell
#download Module 
$modulePath = Join-Path ($Env:PSModulePath.Split(';') -like "$($env:ProgramFiles)*WindowsPowerShell*")[0] 'brickBOX'
if (Test-Path $modulePath) { New-Item $modulePath -ItemType Directory | Out-Null }
Invoke-WebRequest 'https://raw.githubusercontent.com/pageBOX/brickBOX/main/brickBOX.psm1' -OutFile (Join-Path $modulePath 'brickBOX.psm1')
Invoke-WebRequest 'https://raw.githubusercontent.com/pageBOX/brickBOX/main/brickBOX.psd1' -OutFile (Join-Path $modulePath 'brickBOX.psd1')

#load Module
Import-Module brickBOX -Force
Get-Module brickBOX | fl
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
Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1 
```
