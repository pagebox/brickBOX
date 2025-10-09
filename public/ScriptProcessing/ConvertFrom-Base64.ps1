function ConvertFrom-Base64 {
    <#
    .SYNOPSIS
        Reverts a base64 string into text
    .COMPONENT
        ScriptProcessing
    .DESCRIPTION
        This function reverts a base64 encoded string back into its original text form.
    .EXAMPLE
        PS> ConvertFrom-Base64 'Q2h1Y2hpY2jDpHNjaHRsaQ'
        
        Chuchichäschtli
    .EXAMPLE
        PS> 'QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA' | ConvertFrom-Base64 -Encoding ([System.Text.Encoding]::Unicode)

        Chuchichäschtli
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpUri="https://github.com/pagebox/brickBOX/wiki/ConvertFrom-Base64")]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][string]$Base64String,
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::Utf8
    )
    process {
        # calculate padding (https://en.wikipedia.org/wiki/Base64#Output_padding)
        # about base64: Every 3 bytes of input (string) produces 4 characters of output (base64).
        # When the number of input bytes is not a multiple of 3, padding characters "=" must be added at the end.
        [string]$padding = '=' * (($Base64String.Length % 4) -eq 0 ? 0 : 4 - ($Base64String.Length % 4))

        # [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($Base64String))
        return $Encoding.GetString([Convert]::FromBase64String($Base64String + $padding))
    }
}
