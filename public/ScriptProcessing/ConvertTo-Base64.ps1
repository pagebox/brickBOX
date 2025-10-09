function ConvertTo-Base64 {
    <#
    .SYNOPSIS
        Converts a String into a base64 string
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function converts a string into its base64 representation.
    .EXAMPLE
        PS> ConvertTo-Base64 'Chuchichäschtli'

        Q2h1Y2hpY2jDpHNjaHRsaQ==
    .EXAMPLE
        PS> 'Chuchichäschtli' | ConvertTo-Base64 -Encoding ([System.Text.Encoding]::Unicode)

        QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpUri="https://github.com/pagebox/brickBOX/blob/main/public/ScriptProcessing/ConvertTo-Base64.md")]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][string]$TextString,
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::Utf8
    )
    process {
        return [Convert]::ToBase64String($Encoding.GetBytes($TextString))
    }
}
