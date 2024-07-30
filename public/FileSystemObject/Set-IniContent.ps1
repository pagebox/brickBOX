function Set-IniContent {
    <#
    .SYNOPSIS
        Add or Update key-value pairs in ini-files
    .EXAMPLE
        $payload = Set-IniContent $payload 'color' 'red' 
        sets the color=red in an ini-like content of $payload.
    #>
    param (
        [Parameter(mandatory=$true)][System.Array]$payload,
        [Parameter(mandatory=$true)][string]$key,
        [Parameter(mandatory=$true)][string]$value,
        [Parameter()][string]$section = "",
        [switch]$uncomment = $false
    )
    
    Process{
        [String]$ini = ""
        [String]$cSection = "" # Current Section
        [bool]$hasSet = $false

        foreach ($line in $payload.Split("`n")) { 
            $line = $line.Replace("`r","") # remove CR

            if ($line -eq "") { $ini += "$line`r`n"; continue } # Skip empty line
            
            # Section
            if ($line -match "^\[(?<section>.+)\]") {
                if (!$hasSet -and ($cSection -eq $section)) { $ini += "$Key=$value`r`n`r`n$line`r`n" } #value has not yet set, but we're going to leave matching section
                $cSection = $Matches.section
                $ini += "$line`r`n"; continue
            }
            if ($cSection -ne $section) { $ini += "$line`r`n"; continue } # Section doesn't match, skip and continue
            
            
            $isComment = $line -match '^[#;]'
            if (!$uncomment -and $isComment) { $ini += "$line`r`n"; continue } # Skip comments, if we don't want to uncomment

            
            # try to get key-value-pair
            if ($line -match "(?<key>.*)=(?<value>.*)") { # $line is a key-value pair
                
                $cKey = $Matches.key.Trim()
                if ($isComment) { $cKey = $cKey.Substring(1).TrimStart() }  # uncomment sKey

                if ($key.ToLower() -ne $cKey.ToLower()) { $ini += "$line`r`n"; continue } # key and cKey don't match, skip

                if ($line -ne "$cKey=$value" ) {
                    # changing value
                    Write-Verbose "🟠 changing: '$line' => '$cKey=$value' in section [$section]"
                    $ini += "$cKey=$value`r`n"
                } else { # no need to change
                    Write-Verbose "⚪ unchanged: '$line' in section [$section]"
                    $ini += "$line`r`n"
                }
                
                $hasSet = $true

            } else { $ini += "$line`r`n"; continue } # $line is no key-value-pair

        }


        if (!$hasSet) { # value has not yet set.
            if ($cSection -ne $section) { Write-Verbose "adding: section [$section]"; $ini += "`r`n[$section]`r`n" } # we were even missing the section
            Write-Verbose "🟢 adding: '$Key=$value' in section [$section]"
            $ini += "$Key=$value`r`n" 
        } 


        # return (Get-Content $file) -replace $regex, 'https://newurl.com' #| Set-Content $file
        return $ini.Substring(0,$ini.Length-1)
    }
}
