function ConvertTo-Base64 {
    <#
    .SYNOPSIS
        Converts a String into a base64 string
    .COMPONENT
        ScriptProcessing
    .EXAMPLE
        ConvertTo-Base64 'Chuchichäschtli'
    .EXAMPLE
        'Chuchichäschtli' | ConvertTo-Base64 -Encoding ([System.Text.Encoding]::Unicode)
    #>
    [CmdletBinding(SupportsShouldProcess=$false, HelpUri="https://github.com/pagebox/brickBOX/blob/main/public/ScriptProcessing/ConvertTo-Base64.md")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][ValidateNotNull()][string]$TextString,
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::Utf8
    )
    process {
        [Convert]::ToBase64String($Encoding.GetBytes($TextString))
    }
}
