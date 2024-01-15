# brickBOX

A collection of powershell functions, put in a module to make scripting easier. 

The project is available on [PowerShell Gallery](https://www.powershellgallery.com/packages/brickBOX).


## Installation

``` powershell
#download Module 
Install-Module -Name brickBOX -Scope AllUsers
Import-Module brickBOX -Force
Get-Module brickBOX | fl
```

## Functions

**Start-Elevated** Executes a PowerShell script or command with elevated rights  
**Get-Secret** Reads and saves secure strings to hkcu in a secure way.  
**Set-IniContent** Add or Update key-value pairs in ini-files  
**Invoke-API** Simplifies Invoke-RestMethod  


## Testing

### Install Pester

``` powershell
Install-Module Pester -Force -Scope AllUsers
Import-Module Pester -Passthru
```

### Perform Tests

``` powershell
Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1
```

## Upload Package to PowerShell Gallery
``` powershell
Publish-Module -Name brickBOX -NuGetApiKey <apiKey>
```
