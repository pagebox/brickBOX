if ($false) {
    Get-Module brickBOX | Format-Table Name,Version,Path # expect something like "brickBOX 0.0 C:\Data\brickBOX\brickBOX.psm1"
    Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1
    Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1 -FullNameFilter 'Set-Secret, Get-Secret, Clear-Secret'

    # Code Coverage
    $config = New-PesterConfiguration
    $config.Run.Path = ".\tests\"
    $config.CodeCoverage.Enabled = $true
    $config.CodeCoverage.Path = ".\brickBOX.psm1", ".\public"
    $config.CodeCoverage.RecursePaths = $true
    $config.Output.Verbosity = "Detailed"

    Import-Module Pester
    $config = [PesterConfiguration]@{
        Run = @{ Path = ".\tests\"}
        CodeCoverage = @{
            Enabled = $true
            Path = ".\brickBOX.psm1", ".\public", ".\private"
            RecursePaths = $true
            CoveragePercentTarget = 100
        }
        Output = @{ Verbosity = 'Detailed'}
    }
    Invoke-Pester -Configuration $config
}

BeforeAll {
    Remove-Module brickBOX
    Import-Module .\brickBOX.psm1 -Force
    $PSDefaultParameterValues = $null
    $Global:PSDefaultParameterValues = $null

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
        It 'Start-Elevated should not crash' {
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
        It 'Set-Secret should not throw exception' {
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
