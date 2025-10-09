Function Format-Bytes {
    <#
    .SYNOPSIS
        Formats a number to a byte size value
    .COMPONENT
        FileSystemObject
    .DESCRIPTION
        This function formats a number to a byte size value.
    .EXAMPLE
        PS> Format-Bytes 2000
        
        1.95 KB
    .EXAMPLE
        PS> 50000000 | Format-Bytes

        47.68 MB
    .NOTES
        Inspired by https://theposhwolf.com/howtos/Format-Bytes/
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpUri="https://github.com/pagebox/brickBOX/wiki/Format-Bytes")]
    [OutputType([string])]
    Param (
        [Parameter(ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][float]$number
    )
    Process {
        $sizes = 'B','KB','MB','GB','TB','PB'
        if ($number -lt 1kb) { return "$number B" }
        $size = [math]::Log($number,1kb)
        $size = [math]::Floor($size)
        $num = $number / [math]::Pow(1kb,$size)
        return "$($num.ToString("N2")) $($sizes[$size])"
    }
}
