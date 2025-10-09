function Clear-Secret {
    <#
    .SYNOPSIS
        Removes secure strings from hkcu.
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function removes secure strings from the Windows registry under the HKCU hive.
    .EXAMPLE
        PS> Clear-Secret 'myProject' 'myPassword'
        # Removes the 'myPassword' secret form the registry
    .EXAMPLE
        PS> Clear-Secret 'myProject'
        # Removes the whole project 'myProject' with all its secret form the registry
    #>
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/pagebox/brickBOX/wiki/Clear-Secret")]
    param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$projectName,
        [string]$Name = ''
    )
    process {
        if ($Name -eq '') {
            Remove-Item "HKCU:\SOFTWARE\pageBOX\Secret\$projectName\" -ErrorAction SilentlyContinue
        } else {
            Remove-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\$projectName" -Name $Name -ErrorAction SilentlyContinue
        }
    }
}
