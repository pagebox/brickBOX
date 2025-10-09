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

Function Name                                                                                     | Short Description                                                               | Component       
------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | ----------------
[Invoke-API](https://github.com/pagebox/brickBOX/wiki/Invoke-API)                                 | Simplifies Invoke-RestMethod calls                                              | API
[Get-BasicAuthForHeader](https://github.com/pagebox/brickBOX/wiki/Get-BasicAuthForHeader)         | Creates Basic Auth Header Value                                                 | API
[Format-Bytes](https://github.com/pagebox/brickBOX/wiki/Format-Bytes)                             | Formats a number to a byte size value                                           | FileSystemObject
[Set-IniContent](https://github.com/pagebox/brickBOX/wiki/Set-IniContent)                         | Adds or updates key-value pairs in ini-files.                                   | FileSystemObject
[Get-LatestWriteTime](https://github.com/pagebox/brickBOX/wiki/Get-LatestWriteTime)               | Retrieves the latest write time of files in subfolders                          | FileSystemObject
[Convert-IPCalc](https://github.com/pagebox/brickBOX/wiki/Convert-IPCalc)                         | Calculate IP subnet information                                                 | Network
[Test-Admin](https://github.com/pagebox/brickBOX/wiki/Test-Admin)                                 | Checks if the current script is running with administrator privileges.          | ScriptProcessing
[ConvertFrom-Base64](https://github.com/pagebox/brickBOX/wiki/ConvertFrom-Base64)                 | Reverts a base64 string into text                                               | ScriptProcessing
[ConvertTo-Base64](https://github.com/pagebox/brickBOX/wiki/ConvertTo-Base64)                     | Converts a String into a base64 string                                          | ScriptProcessing
[Start-Elevated](https://github.com/pagebox/brickBOX/wiki/Start-Elevated)                         | Executes a PowerShell script or command with elevated rights                    | ScriptProcessing
[ConvertTo-Markdown](https://github.com/pagebox/brickBOX/wiki/ConvertTo-Markdown)                 | Converts a PowerShell object to a Markdown table.                               | ScriptProcessing
[Set-RepeatingScheduledTask](https://github.com/pagebox/brickBOX/wiki/Set-RepeatingScheduledTask) | Creates or ReCreates a Scheduled Task which executes a pwsh script as interval. | ScriptProcessing
[Clear-Secret](https://github.com/pagebox/brickBOX/wiki/Clear-Secret)                             | Removes secure strings from hkcu.                                               | ScriptProcessing
[Get-Secret](https://github.com/pagebox/brickBOX/wiki/Get-Secret)                                 | Reads secure strings from hkcu.                                                 | ScriptProcessing
[Set-Secret](https://github.com/pagebox/brickBOX/wiki/Set-Secret)                                 | Saves secure strings to hkcu in a secure way.                                   | ScriptProcessing


