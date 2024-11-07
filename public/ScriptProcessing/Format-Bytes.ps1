Function Format-Bytes {
    <#
    .SYNOPSIS
        Formats a number to a byte size value
    .COMPONENT
        FileSystemObject
    .EXAMPLE
        Format-Bytes 2000
        
        returns "1.95 KB"
    .EXAMPLE
        2000 | Format-Bytes 
        
        returns "1.95 KB"
    .NOTES
        Inspired by https://theposhwolf.com/howtos/Format-Bytes/
    #>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][float]$number
    )
    Begin {
        $sizes = 'B','KB','MB','GB','TB','PB'
    }
    Process {
        if ($number -lt 1kb) {return "$number B"}
        $size = [math]::Log($number,1kb)
        $size = [math]::Floor($size)
        $num = $number / [math]::Pow(1kb,$size)
        return "$($num.ToString("N2")) $($sizes[$size])"
    }
}
