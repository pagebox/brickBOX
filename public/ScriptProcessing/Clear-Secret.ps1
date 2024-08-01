function Clear-Secret {
    <#
    .SYNOPSIS
        Removes secure strings from hkcu.
    .COMPONENT
        ScriptProcessing
    .EXAMPLE
        Clear-Secret 'myProject' 'myPassword'
        Removes the 'myPassword' secret form the registry
    .EXAMPLE
        Clear-Secret 'myProject'
        Removes the whole project 'myProject' with all its secret form the registry
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$projectName,
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
