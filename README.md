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

Function                | Description
----------------------- | -----------
Test-Admin              | Returns $true, if script runs with administrator privileges  
Start-Elevated          | Executes a PowerShell script or command with elevated rights  
Set-Secret              | Saves secure strings to hkcu in a secure way.  
Get-Secret              | Reads secure strings from hkcu.  
Clear-Secret            | Removes secure strings from hkcu.
Set-IniContent          | Add or Update key-value pairs in ini-files  
Get-BasicAuthForHeader  | Creates the content of the value for the 'Authorization' Property.
Invoke-API              | Simplifies Invoke-RestMethod  


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

### Code Coverage
``` powershell
$config = New-PesterConfiguration
$config.Run.Path = ".\tests\"
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = ".\brickBOX.psm1"
$config.Output.Verbosity = "Detailed"
Invoke-Pester -Configuration $config
```


## Upload Package to PowerShell Gallery
``` powershell
Publish-Module -Name .\brickBOX.psm1 -NuGetApiKey (Get-Secret 'powershellgallery' 'ApiKey' -AsPlainText)
```
