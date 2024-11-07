function ConvertTo-Base64 {
    <#
    .SYNOPSIS
        Converts a String into a base64 string
    .COMPONENT
        ScriptProcessing
    .EXAMPLE
        ConvertTo-Base64 'Chuchichäschtli'
    .EXAMPLE
        ConvertTo-Base64 'Chuchichäschtli' -Encoding ([text.encoding]::Unicode)
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$TextString,

        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::Utf8
    )
    process {
        [Convert]::ToBase64String($Encoding.GetBytes($TextString))
    }
}
