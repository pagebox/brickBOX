function Clear-Secret {
    <#
    .SYNOPSIS
        Removes secure strings from hkcu.
    .EXAMPLE
        Clear-Secret 'myProject' 'myPassword'
        Removes the 'myPassword' secret form the registry
    .EXAMPLE
        Clear-Secret 'myProject'
        Removes the whole project 'myProject' with all its secret form the registry
    #>
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$projectName,
        [string]$Name = ''
    )
    if ($Name -eq '') {
        Remove-Item "HKCU:\SOFTWARE\pageBOX\Secret\$projectName\" -ErrorAction SilentlyContinue
    } else {
        Remove-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\$projectName" -Name $Name -ErrorAction SilentlyContinue
    }
}
