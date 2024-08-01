Function Convert-IPCalc {
    <#
    .SYNOPSIS
        Convert-IPCalc calculates the IP subnet information based upon the entered IP address and subnet. 
    .COMPONENT
        Network
    .EXAMPLE
        Convert-IPCalc 10.10.100.5/24
    .EXAMPLE
        Convert-IPCalc -IPAddress 10.100.100.1 -NetMask 255.255.255.0 
    .EXAMPLE
        Convert-IPCalc 192.168.0.1/24 -IncludeBinaryOutput
    .NOTES
        Inspired by Jason Wasser
    #>
    [CmdletBinding()]
    param (
        # Enter the IP address by itself or with CIDR notation.
        [Parameter(Mandatory=$True,Position=1)][string]$IPAddress,
        # Enter the subnet mask information in dotted decimal form.
        [Parameter(Mandatory=$False,Position=2)][string]$Netmask,
        # Include the binary format of the subnet information.
        [switch]$IncludeBinaryOutput
    )
    process {
        # Function to convert IP address string to binary
        function toBinary ($dottedDecimal) {
            $dottedDecimal.split(".") | ForEach-Object { $binary += $([convert]::toString($_,2).padleft(8,"0")) }
            return $binary
        }

        # Function to binary IP address to dotted decimal string
        function toDottedDecimal ($binary) {
            do { $dottedDecimal += ".$([string]$([convert]::toInt32($binary.substring($i,8),2)))"; $i+=8 } while ($i -le 24)
            return $dottedDecimal.substring(1)
        }

        # Function to convert CIDR format to binary
        function CidrToBin ($cidr) {
            if($cidr -le 32) {
                [Int[]]$array = (1..32)
                for ($i=0;$i -lt $array.length;$i++) {
                    if($array[$i] -gt $cidr) {$array[$i]="0"} else {$array[$i]="1"}
                }
            }
            return $array -join ""
        }

        # Function to convert network mask to wildcard format
        function NetMasktoWildcard ($wildcard) {
            foreach ($bit in [char[]]$wildcard) {
                if ($bit -eq "1") { $wildcardmask += "0" } 
                elseif ($bit -eq "0") { $wildcardmask += "1" }
            }
            return $wildcardmask
        }

        # Check to see if the IP Address was entered in CIDR format.
        if ($IPAddress -like "*/*") {
            $CIDRIPAddress = $IPAddress
            $IPAddress = $CIDRIPAddress.Split("/")[0]
            $cidr = [convert]::ToInt32($CIDRIPAddress.Split("/")[1])
            if ($cidr -in 1..32 ) {
                $ipBinary = toBinary $IPAddress
                Write-Verbose $ipBinary
                $smBinary = CidrToBin($cidr)
                Write-Verbose $smBinary
                $Netmask = toDottedDecimal($smBinary)
                $wildcardbinary = NetMasktoWildcard ($smBinary)
            } else { throw "Subnet Mask is invalid!" }
        } else { # Address was not entered in CIDR format.
            if (!$Netmask) { throw 'Subnet Mask is missing!' }
            $ipBinary = toBinary $IPAddress
            if ($Netmask -eq "0.0.0.0") { throw "Subnet Mask is invalid!" }
            else {
                $smBinary = toBinary $Netmask
                $wildcardbinary = NetMasktoWildcard ($smBinary)
            }
        }

        $netBits = $smBinary.indexOf("0") # First determine the location of the first zero in the subnet mask in binary (if any)

        # If there is a 0 found then the subnet mask is less than 32 (CIDR).
        if ($netBits -ne -1) {
            $cidr = $netBits
            if (($smBinary.length -ne 32) -or ($smBinary.substring($netBits).contains("1"))) { throw "Subnet Mask is invalid!" } # Validate the subnet mask
            if ($ipBinary.length -ne 32) { throw "IP Address is invalid!" } # Validate the IP address
            #identify subnet boundaries
            $networkID = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(32,"0"))
            $networkIDbinary = $ipBinary.substring(0,$netBits).padright(32,"0")
            $firstAddress = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(31,"0") + "1")
            $firstAddressBinary = $($ipBinary.substring(0,$netBits).padright(31,"0") + "1")
            $lastAddress = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(31,"1") + "0")
            $lastAddressBinary = $($ipBinary.substring(0,$netBits).padright(31,"1") + "0")
            $broadCast = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(32,"1"))
            $broadCastbinary = $ipBinary.substring(0,$netBits).padright(32,"1")
            $wildcard = toDottedDecimal ($wildcardbinary)
            $Hostspernet = ([convert]::ToInt32($broadCastbinary,2) - [convert]::ToInt32($networkIDbinary,2)) - 1

        } else { # Subnet mask is 32 (CIDR)
            if($ipBinary.length -ne 32) { throw "IP Address is invalid!" } # Validate the IP address
            #identify subnet boundaries
            $networkID = toDottedDecimal $($ipBinary)
            $networkIDbinary = $ipBinary
            $firstAddress = toDottedDecimal $($ipBinary)
            $firstAddressBinary = $ipBinary
            $lastAddress = toDottedDecimal $($ipBinary)
            $lastAddressBinary = $ipBinary
            $broadCast = toDottedDecimal $($ipBinary)
            $broadCastbinary = $ipBinary
            $wildcard = toDottedDecimal ($wildcardbinary)
            $Hostspernet = 1
            $cidr = 32
        }

        # Output custom object with or without binary information.
        $Output = [PSCustomObject]@{
            Address = $IPAddress
            Netmask = $Netmask
            Wildcard = $wildcard
            Network = "$networkID/$cidr"
            Broadcast = $broadCast
            HostMin = $firstAddress
            HostMax = $lastAddress
            'Hosts/Net' = $Hostspernet
        }
        if ($IncludeBinaryOutput) {
            $Output | Add-Member -MemberType NoteProperty -Name 'AddressBinary' -Value $ipBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'NetmaskBinary' -Value $smBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'WildcardBinary' -Value $wildcardbinary
            $Output | Add-Member -MemberType NoteProperty -Name 'NetworkBinary' -Value $networkIDbinary
            $Output | Add-Member -MemberType NoteProperty -Name 'HostMinBinary' -Value $firstAddressBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'HostMaxBinary' -Value $lastAddressBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'BroadcastBinary' -Value $broadCastbinary
        }
        $Output
    }
}
