function ConvertFrom-Base64 {
    <#
    .SYNOPSIS
        Reverts a base64 string into text
    .COMPONENT
        ScriptProcessing
    .EXAMPLE
        ConvertFrom-Base64 'Q2h1Y2hpY2jDpHNjaHRsaQ=='
    .EXAMPLE
        ConvertFrom-Base64 'QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA' -Encoding ([text.encoding]::Unicode)
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$Base64String,

        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::Utf8
    )
    process {
        # [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($Base64String))
        $Encoding.GetString([Convert]::FromBase64String($Base64String))
    }
}
