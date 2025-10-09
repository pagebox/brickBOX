function Get-Secret {
    <#
    .SYNOPSIS
        Reads secure strings from hkcu.
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function retrieves a secure string from the Windows registry under the HKCU hive.
    .EXAMPLE
        PS> $password = Get-Secret 'myProject' 'myPassword'
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpUri="https://github.com/pagebox/brickBOX/wiki/Get-Secret")]
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$projectName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Name,
        [switch]$AsPlainText = $false
        )
    process {
        if ((Get-ItemProperty "HKCU:\SOFTWARE\pageBOX\Secret\$projectName\" -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains $Name) {
            $value = (Get-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\$projectName" -Name $Name -ErrorAction SilentlyContinue).$Name | ConvertTo-SecureString
        } else {
            throw "$Name not found in $projectName"
        }

        if ($AsPlainText) { return (New-Object System.Management.Automation.PSCredential 0, $value).GetNetworkCredential().Password }
        return $value 
    }
}
