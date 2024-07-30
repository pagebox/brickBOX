function Set-Secret {
    <#
    .SYNOPSIS
        Saves secure strings to hkcu in a secure way.
    .DESCRIPTION
        The function becomes handy, if you need eg. passwords or api-key in your script, but you don't want to save them in the script.
    .EXAMPLE
        $password = Set-Secret 'myProject' 'SecretName' 'myPassword'
        Saves the password in the registry as SecureString
    #>
    param (
        [Parameter(Mandatory = $true)][string]$projectName,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Secret = $null,
        [switch]$WhatIf = $false
    )
    $regKey = "HKCU:\Software\pageBOX\Secret\$projectName"

    if (![string]::IsNullOrEmpty($Secret)) {
        $value = ConvertTo-SecureString $Secret -AsPlainText
    } else {
        $value = Read-Host "Please enter '$Name'" -AsSecureString
    }

    if (!$WhatIf) {
        if (!(Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
        New-ItemProperty -Path $regKey -Name $Name -Value ($value | ConvertFrom-SecureString) -PropertyType "String" -Force | Out-Null
    }
}
