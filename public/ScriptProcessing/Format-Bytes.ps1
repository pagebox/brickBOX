
Function Format-Bytes {
    # inspired by https://theposhwolf.com/howtos/Format-Bytes/
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
