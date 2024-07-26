if ($false) {
    Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1
    Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1 -FullNameFilter 'Set-Secret, Get-Secret, Clear-Secret'
}


BeforeAll {
    # $PSScriptRoot
    Import-Module .\brickBOX.psm1 -Force -Global; Get-Module brickBOX
    
    $PSDefaultParameterValues = $null

    $iniSample = @"
Name=unknown
#City=nowhere
first=second=off

[colors]
Favorite=Black
"@

}

AfterAll {
    Remove-Item HKCU:\SOFTWARE\pageBOX\Secret\pester\ -ErrorAction SilentlyContinue
}


Describe 'Set-Secret, Get-Secret, Clear-Secret' {
    It 'Set-Secret with -WhatIf' {
        Set-Secret 'pester' 'keyWhatIf' 'password' -WhatIf
        (Get-ItemProperty 'HKCU:\SOFTWARE\pageBOX\Secret\pester\' -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains 'keyWhatIf' | Should -BeFalse
    }
    It 'New secret should not throw exception' {
        {Set-Secret 'pester' 'key' 'test'} | Should -Not -Throw
    }
    It 'saved secret in the registry should exist, be a SecureString and not PlainText' {
        (Get-ItemProperty 'HKCU:\SOFTWARE\pageBOX\Secret\pester\' -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains 'key' | Should -BeTrue
        
        $pw = (Get-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\pester" -Name 'key' -ErrorAction SilentlyContinue).'key'
        $pw | Should -Not -Be 'test'
        {$pw | ConvertTo-SecureString} | Should -Not -Throw
    }
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

Describe 'Set-IniContent' {
    Context 'Simple content, without Section' {
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
    Context 'Content in Section' {
        It 'Change Value in section' {
            $iniSample = Set-IniContent $iniSample 'Favorite' 'Red' 'colors'
            $iniSample -imatch '\[colors](?s)(.*)Favorite=Red' | Should -BeTrue
        }
        It 'Add Value in section' {
            $iniSample = Set-IniContent $iniSample 'Sky' 'Blue' 'colors'
            $iniSample -imatch '\[colors](?s)(.*)Sky=Blue' | Should -BeTrue
        }
    }
    Context 'Content in New Section' {
        It 'Add Value in New Section' {
            $iniSample = Set-IniContent $iniSample 'Favorite' 'Raspberry' 'Flavor'
            $iniSample -imatch '\[Flavor](?s)(.*)Favorite=Raspberry' | Should -BeTrue
            $iniSample -imatch 'Favorite=Raspberry(?s)(.*)\[Flavor]' | Should -Not -BeTrue
        }
    }

}

Describe 'Get-BasicAuthForHeader' {
    Context 'Simple Get' {
        It 'Get predictable AuthString' {
            Get-BasicAuthForHeader -username 'user' -password (ConvertTo-SecureString "password" -AsPlainText -Force) | Should -be 'Basic dXNlcjpwYXNzd29yZA=='
        }
    }
}

Describe 'Invoke-API' {
    Context 'Simple Invoke' {
        It 'Invoke simple get to public api' {
            $apiContent = Invoke-API get "https://api.ipify.org?format=json"
            $apiContent.ip -imatch '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$' | Should -BeTrue
        }
    }
}