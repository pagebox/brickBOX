function Get-BasicAuthForHeader {
    <#
    .SYNOPSIS
        Creates Basic Auth Header Value
    .COMPONENT
        API
    .DESCRIPTION
        This function creates the content of the value for the 'Authorization' Property.
    .EXAMPLE
        PS> Get-BasicAuthForHeader -username 'username' -password (ConvertTo-SecureString "password" -AsPlainText -Force)

        Basic dXNlcm5hbWU6cGFzc3dvcmQ=
    .EXAMPLE
        PS> $PSDefaultParameterValues = @{
            "Invoke-RestMethod:Headers"= @{
                'Authorization' = Get-BasicAuthForHeader -username 'username' -password (ConvertTo-SecureString "password" -AsPlainText -Force)
            }
        }
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpUri="https://github.com/pagebox/brickBOX/wiki/Get-BasicAuthForHeader")]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true)][string]$username,
        [Parameter(Mandatory=$true)][SecureString]$password
    )
    process {
        return "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username`:$((New-Object System.Management.Automation.PSCredential 0, $password).GetNetworkCredential().Password)")))"
    }
}
