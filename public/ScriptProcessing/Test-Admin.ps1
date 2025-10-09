function Test-Admin {
    <#
    .SYNOPSIS
        Checks if the current script is running with administrator privileges.
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function checks if the current script is running with administrator privileges.
    .EXAMPLE
        PS> Test-Admin

        False
    #>
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/pagebox/brickBOX/wiki/Test-Admin")]
    [OutputType([bool])]
    param ()
    process {
        return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }
}
