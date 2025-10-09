function Start-Elevated {
    <#
    .SYNOPSIS
        Executes a PowerShell script or command with elevated rights
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function executes a PowerShell script or command with elevated rights.
    .EXAMPLE
        PS> Start-Elevated 'notepad.exe'
        
        Runs notepad as administrator
    #>
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/pagebox/brickBOX/wiki/Start-Elevated")]
    param(
        [Parameter(Mandatory)][string]$Command,
        [switch]$NoExit 
    )
    process {
        if (!(Test-Admin)) { 
            Write-Host "Script needs elevation: '$Command'" 
            $ArgumentList = [System.Collections.ArrayList]@("-NoProfile", "-ExecutionPolicy Bypass")
            if ($NoExit) { $ArgumentList.Add("-NoExit")}
            $ArgumentList.Add("&$Command")
            Start-Process -Verb RunAs -FilePath powershell.exe  -ArgumentList $ArgumentList
        }
    }
}
