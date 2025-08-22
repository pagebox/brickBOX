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
    .EXAMPLE
        Convert-IPCalc 192.168.0.1/24 -IncludeHostList
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
        [switch]$IncludeBinaryOutput,
        # Include List of all hosts.
        [switch]$IncludeHostList

    )
    process {
        # Function to convert IP address string to binary: "1.2.3.4" => "00000001000000100000001100000100"
        function toBinary ($dottedDecimal) {
            return ($dottedDecimal -split "\." | ForEach-Object { [convert]::ToString($_,2).padleft(8,"0") }) -join ""
        }

        # Function to convert IP address to Int32: "172.22.5.0" => 2887124224
        function toInt32 ([IPAddress]$ip) {
            $bytes = $ip.GetAddressBytes()
            if ([BitConverter]::IsLittleEndian) { [Array]::Reverse($bytes)}
            return [BitConverter]::ToUInt32($bytes, 0)
        }

        # Function to convert binary IP address to dotted decimal string: "00000001000000100000001100000100" => "1.2.3.4"
        function toDottedDecimal ($binary) {
            return (0..3 | ForEach-Object { [string]$([convert]::toInt32($binary.substring($_ * 8, 8), 2)) }) -join "."
        }

        # Function to convert CIDR format to binary: 24 => "11111111111111111111111100000000"
        function CidrToBin ([int]$cidr) {
            return "".PadLeft($cidr,'1').PadRight(32,'0')
        }

        # Function to convert network mask to wildcard format: "11111111111111111111111100000000" => 00000000000000000000000011111111
        function NetMasktoWildcard ($wildcard) {
            return $wildcard -replace 1,2 -replace 0,1 -replace 2,0
        }


        # Check the IP Address format. 
        if ($IPAddress -match '^(?<ip>([0-9]{1,3}\.){3}[0-9]{1,3})(/(?<cidr>[1-9]|[12][0-9]|3[012]))?$') { 
            $IPAddress = $Matches['ip'] 
        } else { 
            throw 'The input of the IP Address is invalid!' 
        }
        $cidr = [convert]::ToInt32($Matches['cidr'])

        # check if IP Address is valid.
        $IPAddress.split(".") | ForEach-Object {
            if ([int]$_ -lt 0 -or [int]$_ -gt 255) { throw "IP Address is invalid!" }
        }
        $ipBinary = toBinary $IPAddress

        # check, if the Netmask and CIDR are both set.
        if ($Netmask -and $cidr -gt 0) { throw 'You can not set both Netmask and CIDR!' }

        # check if neither Netmask nor CIDR is set.
        if (!$Netmask -and $cidr -eq 0) { throw 'You must set either Netmask or CIDR!' }
        
        # check if Netmask is valid.
        $smBinary = if ($Netmask) { toBinary $Netmask } else { CidrToBin($cidr) }
        if ($smBinary -notmatch '^1{1,32}0{0,31}$' -or $smBinary.length -ne 32) { throw "Subnet Mask is invalid!" } # Validate the subnet mask
        
        if (!$Netmask) { $Netmask = toDottedDecimal($smBinary) }
        $wildcardbinary = NetMasktoWildcard $smBinary
        $netBits = $smBinary.indexOf("0") # First determine the location of the first zero in the subnet mask in binary (if any)

        # If there is a 0 found then the subnet mask is less than 32 (CIDR).
        if ($netBits -ne -1) {
            $cidr = $netBits
            #identify subnet boundaries
            $networkIDbinary = $ipBinary.substring(0,$netBits).padright(32,"0")
            $networkID = toDottedDecimal $networkIDbinary
            $firstAddressBinary = $($ipBinary.substring(0,$netBits).padright(31,"0") + "1")
            $firstAddress = toDottedDecimal $firstAddressBinary
            $lastAddressBinary = $($ipBinary.substring(0,$netBits).padright(31,"1") + "0")
            $lastAddress = toDottedDecimal $lastAddressBinary
            $broadCastbinary = $ipBinary.substring(0,$netBits).padright(32,"1")
            $broadCast = toDottedDecimal $broadCastbinary
            $wildcard = toDottedDecimal $wildcardbinary
            $Hostspernet = ([convert]::ToInt32($broadCastbinary,2) - [convert]::ToInt32($networkIDbinary,2)) - 1

        } else { # Subnet mask is 32 (CIDR)
            #identify subnet boundaries
            $networkID = toDottedDecimal $ipBinary
            $networkIDbinary = $ipBinary
            $firstAddress = toDottedDecimal $ipBinary
            $firstAddressBinary = $ipBinary
            $lastAddress = toDottedDecimal $ipBinary
            $lastAddressBinary = $ipBinary
            $broadCast = toDottedDecimal $ipBinary
            $broadCastbinary = $ipBinary
            $wildcard = toDottedDecimal $wildcardbinary
            $Hostspernet = 1
            $cidr = 32
        }

        # Output custom object with or without binary information.
        $Output = [PSCustomObject]@{
            Address = $IPAddress
            Address32 = toInt32 ([IPAddress]$IPAddress)
            Netmask = $Netmask
            Wildcard = $wildcard
            Network = "$networkID/$cidr"
            Broadcast = $broadCast
            HostMin = $firstAddress
            HostMax = $lastAddress
            'Hosts/Net' = $Hostspernet
        }
        if ($IncludeBinaryOutput) {
            $Output | Add-Member -MemberType NoteProperty -Name 'AddressBinary'     -Value $ipBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'NetmaskBinary'     -Value $smBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'WildcardBinary'    -Value $wildcardbinary
            $Output | Add-Member -MemberType NoteProperty -Name 'NetworkBinary'     -Value $networkIDbinary
            $Output | Add-Member -MemberType NoteProperty -Name 'HostMinBinary'     -Value $firstAddressBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'HostMaxBinary'     -Value $lastAddressBinary
            $Output | Add-Member -MemberType NoteProperty -Name 'BroadcastBinary'   -Value $broadCastbinary
        }
        if ($IncludeHostList) {
            $hostList = New-Object System.Collections.Generic.List[System.Object]  # @()
            for ($ip = [Convert]::ToInt64($firstAddressBinary, 2); $ip -le [Convert]::ToInt64($lastAddressBinary, 2); $ip++) {
                $hostList.Add((toDottedDecimal ([Convert]::ToString($ip,2)).padleft(32,"0")))
            }
            $Output | Add-Member -MemberType NoteProperty -Name 'HostList' -Value $hostList
        }
        return $Output
    }
}
