Function ConvertTo-Markdown {
    <#
    .SYNOPSIS
        Converts a PowerShell object to a Markdown table.
    .COMPONENT
        ScriptProcessing
    .EXAMPLE
        Get-Process | Where-Object {$_.mainWindowTitle} | Select-Object ID, Name, Path, Company | ConvertTo-Markdown
     
        This command gets all the processes that have a main window title, and it displays them in a Markdown table format with the process ID, Name, Path and Company.
    .EXAMPLE
        ConvertTo-Markdown (Get-Date)
     
        This command converts a date object to Markdown table format
    .EXAMPLE
        Get-Alias | Select Name, DisplayName | ConvertTo-Markdown
     
        This command displays the name and displayname of all the aliases for the current session in Markdown table format
    .NOTES
        Inspired by https://www.powershellgallery.com/packages/PSMarkdown/1.1
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)][PSObject[]]$InputObject
    )
    Begin {
        $items = @() 
        $maxColLenght = @{} # hashtable
    }
    Process {
        ForEach($item in $InputObject) {
            $item.PSObject.Properties | ForEach-Object {

                if($_.IsSettable) {
                    if($null -eq $_.Value) { $_.Value = "" }
                    if($_.Value.GetType().Name -eq "String") { $_.Value = "$($_.Value)".Replace("`r`n"," ").Trim() }
                }

                # if($_.IsSettable -and $_.Value.GetType().Name -eq "String" ) {$_.Value = "$($_.Value)".Replace("`r`n"," ").Trim()}


                $maxColLenght[$_.Name] = [Math]::Max($_.Value.ToString().Length, $maxColLenght[$_.Name])
            }
            $items += $item
        }
        ForEach($key in $($maxColLenght.Keys)) { # check, if title is longer than longest item
            $maxColLenght[$key] = [Math]::Max($maxColLenght[$key], $key.Length)
        }
    }
    End {
        if ($null -eq $InputObject) { return '' } # Write-Error "InputObject is null"

        $header = @()
        ($InputObject[0].PSObject.Properties).Name | ForEach-Object {
            $header += $_.PadRight($maxColLenght[$_])
        }
        $header -join ' | '

        $separator = @()
        ($InputObject[0].PSObject.Properties).Name | ForEach-Object {
            if ($item.($_).GetType().Name -match 'byte|short|int32|long|sbyte|ushort|uint32|ulong|float|double|decimal') { # isNumeric
                $separator += ":".PadLeft($maxColLenght[$_], "-") 
            } else {
                $separator += "".PadRight($maxColLenght[$_], "-") 
            }
        }
        $separator -join ' | '

        ForEach($item in $items) {
            $values = @()
            ($InputObject[0].PSObject.Properties).Name | ForEach-Object {
                
                if ($null -eq $item.($_)) {
                    $values += "".PadLeft($maxColLenght[$_])
                } elseif ($item.($_).GetType().Name -match 'byte|short|int32|long|sbyte|ushort|uint32|ulong|float|double|decimal') { # isNumeric
                    $values += "$($item.($_))".PadLeft($maxColLenght[$_])
                } else {
                    $values += "$($item.($_))".PadRight($maxColLenght[$_])
                }

            }
            $values -join ' | '
        }
    }
}
