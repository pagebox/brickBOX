BeforeAll {
    Remove-Module brickBOX -Force
    Import-Module $PSScriptRoot\..\brickBOX.psm1 -Force
    $PSDefaultParameterValues = $null
    $Global:PSDefaultParameterValues = $null

}

Describe 'Test TestEnvironment' {
    It 'Test module should be loaded' {
        (Get-Module brickBOX ).count | Should -Be 1
        (Get-Module brickBOX ).Version | Should -Be '0.0'
    }
}

Describe 'Test ScriptProcessing' {
    Context 'Format-Bytes' {
        It 'should be converted correctly' {
            20 | Format-Bytes | Should -Be '20 B'
            1kb | Format-Bytes | Should -Be '1.00 KB'
            1kb + 512 | Format-Bytes | Should -Be '1.50 KB'
            1mb | Format-Bytes | Should -Be '1.00 MB'
            1gb | Format-Bytes | Should -Be '1.00 GB'
            1tb | Format-Bytes | Should -Be '1.00 TB'
            1pb | Format-Bytes | Should -Be '1.00 PB'
            1pb | Format-Bytes | Should -Be '1.00 PB'
        }
    }
    Context 'Test-Admin' {
        It 'Should be of type Boolean' {
            Test-Admin | Should -BeOfType Boolean
        }
    }
    Context 'Start-Elevated' {
        It 'should not throw' {
            Mock -ModuleName brickBOX -CommandName Test-Admin -MockWith {return $false}
            Mock -ModuleName brickBOX -CommandName Start-Process 

            {Start-Elevated 'notepad' -NoExit} | Should -Not -Throw
        }
    }
    Context 'Set-Secret' {
        It 'Set-Secret with -WhatIf' {
            Set-Secret 'pester' 'keyWhatIf' 'password' -WhatIf
            (Get-ItemProperty 'HKCU:\SOFTWARE\pageBOX\Secret\pester\' -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains 'keyWhatIf' | Should -BeFalse
        }
        It 'should not throw' {
            {Set-Secret 'pester' 'key' 'test'} | Should -Not -Throw
        }
        It 'Saved secret in the registry should exist as type of SecureString and not PlainText' {
            (Get-ItemProperty 'HKCU:\SOFTWARE\pageBOX\Secret\pester\' -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains 'key' | Should -BeTrue
            $pw = (Get-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\pester" -Name 'key' -ErrorAction SilentlyContinue).'key'
            {$pw | ConvertTo-SecureString} | Should -Not -Throw
        }
        It 'Set-Secret without name parameter' {
            Mock -ModuleName brickBOX -CommandName Read-Host -MockWith {return (ConvertTo-SecureString "test" -AsPlainText -Force)}
            Set-Secret 'pester' 'keyPrompt'

            $pw = (Get-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\pester" -Name 'keyPrompt' -ErrorAction SilentlyContinue).'keyPrompt'
            {$pw | ConvertTo-SecureString} | Should -Not -Throw
        }
    }
    Context 'Get-Secret' {
        It 'Loaded secret should be of type SecureString and decrypted value should be "test"' {
            $pw = Get-Secret 'pester' 'key'
            $pw | Should -BeOfType System.Security.SecureString
            (New-Object System.Management.Automation.PSCredential 0, $pw).GetNetworkCredential().Password | Should -Be "test"
        }
        It 'Reloaded secret with parameter -AsPlainText should be of type string and value should be "test"' {
            $pw = Get-Secret 'pester' 'key' -AsPlainText
            $pw | Should -BeOfType string
            $pw | Should -Be "test"
        }
        It 'Trying to get a missing secret should throw an exception' {
            {Get-Secret 'pester' 'missing'} | Should -Throw 
        }
        It 'Missing parameter "name" should throw an exception' {
            {Get-Secret 'pester' '' } | Should -Throw 
        }
        It 'Missing parameter "projectName" should throw an exception' {
            {Get-Secret '' 'key' } | Should -Throw 
        }
    }
    Context 'Clear-Secret' {
        It 'Removal of single Secret should succeed.' {
            Clear-Secret 'pester' 'key' 
            (Get-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\pester" -Name 'key' -ErrorAction SilentlyContinue).'key' | Should -BeNullOrEmpty
            {Get-Item -Path "HKCU:\Software\pageBOX\Secret\pester" -ErrorAction SilentlyContinue} | Should -Not -Throw
        }
        It 'Removal of whole Secret project should succeed.' {
            Clear-Secret 'pester'
            Get-Item -Path "HKCU:\Software\pageBOX\Secret\pester" -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }
    }
    Context 'ConvertTo-Markdown' {
        BeforeAll {
            $oMD = @(
                [PSCustomObject]@{ID = 1;Name = 'page'}
                [PSCustomObject]@{ID = 2;}
                [PSCustomObject]@{ID = 3;Name = $null}
                [PSCustomObject]@{ID = 4;Name = "Name`r`nNewLine"}
            )
            if ($oMD){} # ⚠️ false positive warning: variable assigned, but never used
        }
        It 'Should not throw' {
            { ConvertTo-Markdown $oMD } | Should -Not -Throw
        }
        It 'Should render perfectly' {
            $md = ConvertTo-Markdown $oMD
            $md | Should -Contain 'ID | Name        '
            $md | Should -Contain '-: | ------------'
            $md | Should -Contain ' 1 | page        '
            $md | Should -Contain ' 2 |             '
            $md | Should -Contain ' 3 |             '
            $md | Should -Contain ' 4 | Name NewLine'
        }
        It 'Should return empty string' {
           $oMD | Where-Object Name -EQ 'DoesNotExist' | ConvertTo-Markdown | Should -Be ''
        }
    }
    Context 'ConvertTo-Base64' {
        It 'simple convert' {
            ConvertTo-Base64 'Chuchichäschtli' | Should -be 'Q2h1Y2hpY2jDpHNjaHRsaQ=='
        }
        It 'convert with -Encoding Unicode' {
            ConvertTo-Base64 'Chuchichäschtli' -Encoding ([text.encoding]::Unicode) | Should -be 'QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA'
        }
    }
    Context 'ConvertFrom-Base64' {
        It 'simple revert' {
            ConvertFrom-Base64 'Q2h1Y2hpY2jDpHNjaHRsaQ==' | Should -be 'Chuchichäschtli'
        }
        It 'simple revert' {
            ConvertFrom-Base64 'QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA' -Encoding ([text.encoding]::Unicode) | Should -be 'Chuchichäschtli'
        }
    }
    Context 'Set-RepeatingScheduledTask' {
        It 'Create TaskSchedule' {
            Mock -ModuleName brickBOX -CommandName Register-ScheduledTask -MockWith {return ''}
            { Set-RepeatingScheduledTask -ScriptFile (Get-Item $PSScriptRoot\..\brickBOX.psm1) -TaskPath 'test' -User "$env:COMPUTERNAME\$env:USERNAME" -Password (ConvertTo-SecureString "chuchichäschtli" -AsPlainText) } | Should -Not -Throw
        }
    }

    AfterAll {
        Remove-Item HKCU:\SOFTWARE\pageBOX\Secret\pester\ -ErrorAction SilentlyContinue
    }
    
}

Describe 'Test FileSystemObject' {
    BeforeAll {
        $iniSample = @"
#This is a comment
Name=unknown
#City=nowhere
first=second=off

[colors]
Favorite=Black
"@
        if ($iniSample){} # ⚠️ false positive warning: variable assigned, but never used
    }
    Context 'Set-IniContent: Simple content, without Section' {
        It 'Change Value' {
            $iniSample = Set-IniContent $iniSample 'Name' 'Page'
            $iniSample | Should -BeLike '*Name=Page*'
        }
        It 'Adding Key-Value' {
            $iniSample = Set-IniContent $iniSample 'Zip' '6340'
            $iniSample | Should -BeLike '*Zip=6340*'
        }
        It 'Adding Key-Value without uncommenting' {
            $iniSample = Set-IniContent $iniSample 'City' 'Baar'
            $iniSample | Should -BeLike '*City=Baar*'
            $iniSample | Should -BeLike '*#City=nowhere*'
        }
        It 'Adding Key-Value with uncommenting' {
            $iniSample = Set-IniContent $iniSample 'City' 'Baar' -uncomment
            $iniSample | Should -BeLike '*City=Baar*'
            $iniSample | Should -Not -BeLike '*#City=nowhere*'
        }
        It 'Changing double equation' {
            $iniSample = Set-IniContent $iniSample 'first=second' 'on'
            $iniSample | Should -Not -BeLike '*first=second=off*'
            $iniSample | Should -BeLike '*first=second=on*'
        }
    }
    Context 'Set-IniContent: Content in Section' {
        It 'Change Value in section where no change is needed' {
            $iniSample = Set-IniContent $iniSample 'Favorite' 'Black' 'colors'
            $iniSample -imatch '\[colors](?s)(.*)Favorite=Black' | Should -BeTrue
        }
        It 'Change Value in section' {
            $iniSample = Set-IniContent $iniSample 'Favorite' 'Red' 'colors'
            $iniSample -imatch '\[colors](?s)(.*)Favorite=Red' | Should -BeTrue
        }
        It 'Add Value in section' {
            $iniSample = Set-IniContent $iniSample 'Sky' 'Blue' 'colors'
            $iniSample -imatch '\[colors](?s)(.*)Sky=Blue' | Should -BeTrue
        }
    }
    Context 'Set-IniContent: Content in New Section' {
        It 'Add Value in New Section' {
            $iniSample = Set-IniContent $iniSample 'Favorite' 'Raspberry' 'Flavor'
            $iniSample -imatch '\[Flavor](?s)(.*)Favorite=Raspberry' | Should -BeTrue
            $iniSample -imatch 'Favorite=Raspberry(?s)(.*)\[Flavor]' | Should -Not -BeTrue
        }
    }
    Context 'Get-LatestWriteTime' {
        It 'should not throw' {
            {Get-LatestWriteTime '.'} | Should -Not -Throw
        }
    }

}

Describe 'Test Network' {
    Context 'Convert-IPCalc' {
        It 'Simple calc' {
            $ip = Convert-IPCalc 10.10.100.5/24
            $ip.Address         | Should -be '10.10.100.5'
            $ip.Address32       | Should -be 168453125
            $ip.Netmask         | Should -be '255.255.255.0'
            $ip.Wildcard        | Should -be '0.0.0.255'
            $ip.Network         | Should -be '10.10.100.0/24'
            $ip.Broadcast       | Should -be '10.10.100.255'
            $ip.HostMin         | Should -be '10.10.100.1'
            $ip.HostMax         | Should -be '10.10.100.254'
            $ip.'Hosts/Net'     | Should -be '254'
            $ip.AddressBinary   | Should -Be $null
        }
        It 'Simple calc with /32' {
            $ip = Convert-IPCalc 255.10.100.5/32
            $ip.Address         | Should -be '255.10.100.5'
            $ip.Address32       | Should -be 4278871045
            $ip.Netmask         | Should -be '255.255.255.255'
            $ip.Wildcard        | Should -be '0.0.0.0'
            $ip.Network         | Should -be '255.10.100.5/32'
            $ip.Broadcast       | Should -be '255.10.100.5'
            $ip.HostMin         | Should -be '255.10.100.5'
            $ip.HostMax         | Should -be '255.10.100.5'
            $ip.'Hosts/Net'     | Should -be '1'
            $ip.AddressBinary   | Should -be $null
        }
        It 'Calc with IncludeBinaryOutput' {
            $ip = Convert-IPCalc 10.10.100.5/24 -IncludeBinaryOutput
            $ip.AddressBinary   | Should -be '00001010000010100110010000000101'
            $ip.NetmaskBinary   | Should -be '11111111111111111111111100000000'
            $ip.WildcardBinary  | Should -be '00000000000000000000000011111111'
            $ip.NetworkBinary   | Should -be '00001010000010100110010000000000'
            $ip.HostMinBinary   | Should -be '00001010000010100110010000000001'
            $ip.HostMaxBinary   | Should -be '00001010000010100110010011111110'
            $ip.BroadcastBinary | Should -be '00001010000010100110010011111111'
        }
        It 'Calc with IncludeHostList' {
            $ip = Convert-IPCalc 10.10.100.5/26 -IncludeHostList
            $ip.'Hosts/Net' -eq $ip.HostList.Count | Should -BeTrue
            $ip.HostList[2]     | Should -be '10.10.100.3'
            $ip.HostList[-1]    | Should -be '10.10.100.62'
        }
        It 'Test Subnet Mask & CIDR validation' {
            { Convert-IPCalc 10.10.100.5 }      | Should -Throw
            { Convert-IPCalc 10.10.100.5/24 -Netmask '255.255.255.0' } | Should -Throw
            { Convert-IPCalc 10.10.100.5/33 }   | Should -Throw
            { Convert-IPCalc 10.10.100.5/abc }  | Should -Throw
            { Convert-IPCalc 10.10.100.5/-10 }  | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask '0.0.0.0' }   | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask '257.0.0.0' } | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask '-55.0.0.0' } | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask '255.255.0' } | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask '255.0.0.0.0' } | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask '255.0.255.0' } | Should -Throw
            { Convert-IPCalc 10.10.100.5 -Netmask 'abc.0.0.0' } | Should -Throw
        }
        It 'Test IP Address' {
            { Convert-IPCalc 257.1.1.5/24 } | Should -Throw
            { Convert-IPCalc -57.1.1.5/24 } | Should -Throw
            { Convert-IPCalc abc.1.1.5/24 } | Should -Throw
            { Convert-IPCalc 1.1.1.1.1/24 } | Should -Throw
            { Convert-IPCalc 10.10.10/24 }  | Should -Throw
            { Convert-IPCalc 257.1.1.5/32 } | Should -Throw
        }
    }
}

Describe 'Test API' {
    Context 'Get-BasicAuthForHeader' {
        It 'Get predictable AuthString' {
            Get-BasicAuthForHeader -username 'user' -password (ConvertTo-SecureString "password" -AsPlainText -Force) | Should -be 'Basic dXNlcjpwYXNzd29yZA=='
        }
    }
    Context 'Invoke-API' {
        It 'Invoke simple GET to public api' {
            $apiContent = Invoke-API get "https://api.ipify.org?format=json"
            $apiContent.ip -imatch '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$' | Should -BeTrue
        }
        It 'Invoke simple POST to public api' {
            $apiContent = Invoke-API post "https://httpbin.org/post" -Payload '{"Id": 12345 }'
            $apiContent.data | Should -Not -BeNullOrEmpty
        }
        It 'Invoke simple POST to public api with $PSDefaultParameterValues' {
            $Global:PSDefaultParameterValues = @{
                "Invoke-RestMethod:Headers"= @{
                    'Accept' = "application/json"
                    'customHeader' = 'byDefParam'
                }
                "Invoke-RestMethod:ContentType"="application/json; charset=utf-8"
            }
            $apiContent = Invoke-API post "https://httpbin.org/post" -Payload '{"Id": 12345 }'
            $apiContent.headers.customHeader | Should -be 'byDefParam'
            $Global:PSDefaultParameterValues = $null
        }
        It 'Mock ServiceNow payload' {
            Mock -ModuleName brickBOX -CommandName Invoke-RestMethod -MockWith {return @{'result' = 'ServiceNow'}}
            
            $apiContent = Invoke-API get "https://ServiceNow" 
            $apiContent | Should -Be 'ServiceNow'
        }
    }
}
