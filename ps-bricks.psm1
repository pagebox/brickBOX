<#
.SYNOPSIS
    A collection of powershell functions, put in a module to make scripting easier
.LINK 
    https://github.com/pagebox/ps-bricks

#>



#region "⚡ ScriptProcessing"


<#
.SYNOPSIS
    Executes a PowerShell script or command with elevated rights
.EXAMPLE
    Start-Elevated notepad.exe
    Runs notepad as administrator
#>
function Start-Elevated {
    param(
        [Parameter(Mandatory)][string]$Command,
        [switch]$NoExit 
    )

    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
        Write-Host "Script needs elevation: '$Command'" 
        $ArgumentList = [System.Collections.ArrayList]@("-NoProfile", "-ExecutionPolicy Bypass")
        if ($NoExit) { $ArgumentList.Add("-NoExit")}
        $ArgumentList.Add("&$Command")
        Start-Process -Verb RunAs -FilePath powershell.exe  -ArgumentList $ArgumentList
    }
}
Export-ModuleMember -Function Start-Elevated


<#
.SYNOPSIS
    Reads and saves secure strings to hkcu in a secure way.
.DESCRIPTION
    The function becomes handy, if you need eg. passwords or api-key in your script, but you don't want to save them in the script.
.EXAMPLE
    $password = Get-Secret 'myProject' 'myPassword'
    saves the prompted password in the registry and sets $password as SecureString
#>
function Get-Secret {
    param (
        [Parameter(Mandatory = $true)][string]$projectName,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Secret = $null,
        [switch]$AsPlainText = $false,
        [switch]$Save = $false
    )
    $regKey = "HKCU:\Software\pageBOX\Secret\$projectName"
    $value = Get-ItemProperty -Path $regKey -Name $Name -ErrorAction SilentlyContinue
    if ($value) {
        $value = $value.$Name | ConvertTo-SecureString
    } else {
        if ($null -ne $Secret) {
            $value = ConvertTo-SecureString $Secret -AsPlainText
        } else {
            $value = Read-Host "Please enter '$Name'" -AsSecureString
        }
        if ($Save -or $Host.UI.PromptForChoice('Confirm:', 'Do you want to save password to Registry?', ('&Yes', '&No'), 0) -eq 0) {
            if (!(Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $Name -Value ($value | ConvertFrom-SecureString) -PropertyType "String" -Force | Out-Null
        }
    }

    if ($AsPlainText) { return (New-Object System.Management.Automation.PSCredential 0, $value).GetNetworkCredential().Password }
    return $value 
}
Export-ModuleMember -Function Get-Secret

#endregion


