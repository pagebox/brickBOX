function Set-Secret {
    <#
    .SYNOPSIS
        Saves secure strings to hkcu in a secure way.
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function saves a secure string to the Windows registry under the HKCU hive. It can either take a plain text secret as input or prompt the user to enter it securely. 
        The secret is stored in an encrypted format using PowerShell's ConvertFrom-SecureString cmdlet.
    .EXAMPLE
        PS> $password = Set-Secret 'myProject' 'SecretName' 'myPassword'
    #>
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/pagebox/brickBOX/wiki/Set-Secret")]
    param (
        [Parameter(Mandatory = $true)][string]$projectName,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Secret = $null
    )
    process {
        $regKey = "HKCU:\Software\pageBOX\Secret\$projectName"

        if (![string]::IsNullOrEmpty($Secret)) {
            $value = ConvertTo-SecureString $Secret -AsPlainText
        } else {
            $value = Read-Host "Please enter '$Name'" -AsSecureString
        }

        if($PSCmdlet.ShouldProcess($Name, "Write secret to registry")){
            if (!(Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $Name -Value ($value | ConvertFrom-SecureString) -PropertyType "String" -Force | Out-Null
        }
    }
}
