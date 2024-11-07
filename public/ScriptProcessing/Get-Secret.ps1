function Get-Secret {
    <#
    .SYNOPSIS
        Reads secure strings from hkcu.
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        The function becomes handy, if you need eg. passwords or api-key in your script, but you don't want to save them in the script.
    .EXAMPLE
        $password = Get-Secret 'myProject' 'myPassword'
        Gets the password earlier saved from the registry and sets $password as SecureString
    #>
    [CmdletBinding()]
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
