function Test-Admin {
    <#
    .SYNOPSIS
    Returns $true, if script runs with administrator privileges
    
    #>
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}