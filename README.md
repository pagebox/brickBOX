# brickBOX

A collection of powershell functions, put in a module to make scripting easier.  

Highlights of the module are:  
`Set-Secret` and `Get-Secret` which can save and load password very convenient in a save, encrypted way.  
`Invoke-API` which is a wrapper for `Invoke-RestMethod` to simplify API calls.  
`Set-IniContent` allows you easily add or update key-value pairs in ini-files.  
`Start-Elevated` makes sure your script runns with admin privileges (prompts for elevation).  

The module complies big parts of the [PowerShell Best Practice and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/).

The project is available on [PowerShell Gallery](https://www.powershellgallery.com/packages/brickBOX).


## Installation

Best, easiest and recommended way to install the module is over _PowerShell Gallery_:

``` powershell
# download and install Module 
Install-Module -Name brickBOX -Scope AllUsers

# Add module to the current session
Import-Module brickBOX -Force
Get-Module brickBOX | fl
```

Alternatively you can clone the module from github and import the module directly:

``` powershell
Import-Module $PSScriptRoot\brickBOX.psm1 -Force
```

## Functions

Complete list of all Functions

Name                       | Description                                                                                                                              | Component       
-------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------
Invoke-API                 | Simplifies Invoke-RestMethod                                                                                                             | API
Get-BasicAuthForHeader     | Creates the content of the value for the 'Authorization' Property.                                                                       | API
Format-Bytes               | Formats a number to a byte size value                                                                                                    | FileSystemObject
Set-IniContent             | Add or Update key-value pairs in ini-files                                                                                               | FileSystemObject
Get-LatestWriteTime        | Returns a list of objects of given folder as input. Output contains information about the most latest written file within any subfolder. | FileSystemObject
Convert-IPCalc             | Convert-IPCalc calculates the IP subnet information based upon the entered IP address and subnet.                                        | Network
Test-Admin                 | Returns $true, if script runs with administrator privileges                                                                              | ScriptProcessing
ConvertFrom-Base64         | Reverts a base64 string into text                                                                                                        | ScriptProcessing
ConvertTo-Base64           | Converts a String into a base64 string                                                                                                   | ScriptProcessing
Start-Elevated             | Executes a PowerShell script or command with elevated rights                                                                             | ScriptProcessing
ConvertTo-Markdown         | Converts a PowerShell object to a Markdown table.                                                                                        | ScriptProcessing
Set-RepeatingScheduledTask | Creates or ReCreates a Scheduled Task which executes a pwsh script as interval.                                                          | ScriptProcessing
Clear-Secret               | Removes secure strings from hkcu.                                                                                                        | ScriptProcessing
Get-Secret                 | Reads secure strings from hkcu.                                                                                                          | ScriptProcessing
Set-Secret                 | Saves secure strings to hkcu in a secure way.                                                                                            | ScriptProcessing


