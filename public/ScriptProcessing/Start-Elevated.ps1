function Start-Elevated {
    <#
    .SYNOPSIS
        Executes a PowerShell script or command with elevated rights
    .EXAMPLE
        Start-Elevated notepad.exe
        Runs notepad as administrator
    #>
    param(
        [Parameter(Mandatory)][string]$Command,
        [switch]$NoExit 
    )

    if (!(Test-Admin)) { 
        Write-Host "Script needs elevation: '$Command'" 
        $ArgumentList = [System.Collections.ArrayList]@("-NoProfile", "-ExecutionPolicy Bypass")
        if ($NoExit) { $ArgumentList.Add("-NoExit")}
        $ArgumentList.Add("&$Command")
        Start-Process -Verb RunAs -FilePath powershell.exe  -ArgumentList $ArgumentList
    }
}
