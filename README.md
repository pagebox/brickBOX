# ps-bricks

A collection of powershell functions, put in a module to make scripting easier

## Installation

``` powershell
Import-Module ps-bricks.psm1 -Force
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

