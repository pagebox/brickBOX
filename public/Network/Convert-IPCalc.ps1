Function Convert-IPCalc {
    <#
    .SYNOPSIS
        Calculate IP subnet information
    .COMPONENT
        Network
    .DESCRIPTION
        This function calculates the IP subnet information based upon the entered IP address and subnet. 
        It can accept either CIDR notation or a subnet mask in dotted decimal format. 
        The output includes details such as the network address, broadcast address, host range, and the number of hosts per subnet. 
        Optional parameters allow for the inclusion of binary representations of the IP addresses and a list of all possible host addresses within the subnet.
    .EXAMPLE
        PS> Convert-IPCalc 10.10.100.5/24

        Address   : 10.10.100.5
        Address32 : 168453125
        Netmask   : 255.255.255.0
        Wildcard  : 0.0.0.255
        Network   : 10.10.100.0/24
        Broadcast : 10.10.100.255
        HostMin   : 10.10.100.1
        HostMax   : 10.10.100.254
        Hosts/Net : 254
    .EXAMPLE
        PS> Convert-IPCalc -IPAddress 10.100.100.1 -NetMask 255.255.255.0

        Address   : 10.100.100.1
        Address32 : 174351361
        Netmask   : 255.255.255.0
        Wildcard  : 0.0.0.255
        Network   : 10.100.100.0/24
        Broadcast : 10.100.100.255
        HostMin   : 10.100.100.1
        HostMax   : 10.100.100.254
        Hosts/Net : 254
    .EXAMPLE
        PS> Convert-IPCalc 192.168.0.1/24 -IncludeBinaryOutput

        Address         : 192.168.0.1
        Address32       : 3232235521
        Netmask         : 255.255.255.0
        Wildcard        : 0.0.0.255
        Network         : 192.168.0.0/24
        Broadcast       : 192.168.0.255
        HostMin         : 192.168.0.1
        HostMax         : 192.168.0.254
        Hosts/Net       : 254
        AddressBinary   : 11000000101010000000000000000001
        NetmaskBinary   : 11111111111111111111111100000000
        WildcardBinary  : 00000000000000000000000011111111
        NetworkBinary   : 11000000101010000000000000000000
        HostMinBinary   : 11000000101010000000000000000001
        HostMaxBinary   : 11000000101010000000000011111110
        BroadcastBinary : 11000000101010000000000011111111
    .EXAMPLE
        PS> Convert-IPCalc 192.168.0.1/24 -IncludeHostList

        Address   : 192.168.0.1
        Address32 : 3232235521
        Netmask   : 255.255.255.0
        Wildcard  : 0.0.0.255
        Network   : 192.168.0.0/24
        Broadcast : 192.168.0.255
        HostMin   : 192.168.0.1
        HostMax   : 192.168.0.254
        Hosts/Net : 254
        HostList  : {192.168.0.1, 192.168.0.2, 192.168.0.3, 192.168.0.4…}
    .NOTES
        Inspired by Jason Wasser
    #>
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/pagebox/brickBOX/wiki/Convert-IPCalc")]
    [OutputType([PSCustomObject])]
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

# SIG # Begin signature block
# MIIFsAYJKoZIhvcNAQcCoIIFoTCCBZ0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAZfzO0DJumZZJY
# +elxpDcmghh0D9tkYFzo33nK8qgZoKCCAxwwggMYMIICAKADAgECAhB9XzvMF9qV
# mE6NV/UQOTeSMA0GCSqGSIb3DQEBCwUAMCQxIjAgBgNVBAMMGXBhZ2VCT1ggQ29k
# ZSBTaWduaW5nIENlcnQwHhcNMjUwMzAyMTYzODA3WhcNMjYwMzAyMTY1ODA3WjAk
# MSIwIAYDVQQDDBlwYWdlQk9YIENvZGUgU2lnbmluZyBDZXJ0MIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuUDEhiZHE+UCgzTjpgGWX2yRIRbWBxrG0cos
# stAM29Euk+IsbqVUlYk9/oOWHTm1G+h1uSJrsdtobERzogZo6RyYxH2wEQN+qaBc
# 8rn9bc9K+jgnth5mdy4k4VsjVoGVCmjDDSvf1I6iwtvLUgc16KGYp6T/occVu3LD
# qb90y2H53sw/+0k5V6yuE2SD3lKp3WtM4q51fPLmcsgOB5LjIUQmJV7e9wSMPn4A
# jGQSOCgUCIEC+2CB22NE7JPKeP2o1euspimz3VhaHMGYJCY98jYGjCgUjA9DBN8k
# 6h/US1yzlxsZLnnDNGkMQBCjBiTiDZVNSJR7qii7uJaWDo0ruQIDAQABo0YwRDAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFOYq
# A5c0jwfTLfmIHxx+TPuJ44jcMA0GCSqGSIb3DQEBCwUAA4IBAQA7b6EZZtvZISJC
# cE88X9qlaTCUSj0WPfbm90Mj1luN4wQMUrWwSxxMzrrMrXSQBXAA8CCtK02kkeZm
# I35QTf4wVcwU9rZcTJs/WXwRXUDQw9Er02ILTP6BeE/V8NyQCijEziE2hammMKP7
# yaE7uCNyDEi+LIVugSlSotZZE2I4ca9cpqYUiYWNMJbiKKMkmvqUMsQegI+CVu3r
# HPyy7I58ZX2nIJpibGXFAb/8RO/b6H2fQm0Lylx8MHBCeaO0w3W6T9LTKBOlmEs2
# LJbdYyqkuMh8I/IPlnWRfpRx7CGdBcdWSt8BgTiz7kUaKLhqZPfRQPZeL3+TPNEY
# Qt9HBhbZMYIB6jCCAeYCAQEwODAkMSIwIAYDVQQDDBlwYWdlQk9YIENvZGUgU2ln
# bmluZyBDZXJ0AhB9XzvMF9qVmE6NV/UQOTeSMA0GCWCGSAFlAwQCAQUAoIGEMBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIE
# IHc63Z2FIX6r+5IROsbGwKNa/fnTn/PKj43M2IbbiKATMA0GCSqGSIb3DQEBAQUA
# BIIBAKQA384XRhpxi7MUlN+9yCSLmSRS/Ih3rsVuvoA/kOJMkE9QP0x4/KueoPjW
# Clj5zq6QUhg+/YXv/h+YHUprBE0tVXxkvAY+q75STttzcEmgsg0Yf/XVmMwRKP2E
# ErsN1bvMrwD40TGcLXBJ5EhfRl5O1RzgyQyYa6GDAN2pAvXLN86HKTTPxKNH/vT4
# uMYTAvyib20eUPcxFVaAqnVeyx9OzMfG9RyzdAyGCkWyixzauJcN1FssYdXKiLKz
# Ce4IlBC8dIN2kt9xV42gjS1rBm/96+UHoaBjmHENPWOtNd1jtOKDJNB/WI7QQa8M
# 9D3RWkMBM6/TnXgXoHA7mZJDuZA=
# SIG # End signature block
