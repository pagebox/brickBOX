BeforeAll {
    # $PSScriptRoot
    Import-Module .\brickBOX.psm1 -Force

    $iniSample = @"
Name=unknown
#City=nowhere
dtparam=audio=off

[colors]
Favorite=Black
"@

}

AfterAll {
    Remove-Item HKCU:\SOFTWARE\pageBOX\Secret\pester\ -ErrorAction SilentlyContinue
}



Describe 'Get-Secret' {
    It 'New secret should be of type SecureString and decrypted value should be "test"' {
        $pw = Get-Secret 'pester' 'key' -Save -Secret "test"
        $pw | Should -BeOfType System.Security.SecureString
        (New-Object System.Management.Automation.PSCredential 0, $pw).GetNetworkCredential().Password | Should -Be "test"
    }
    It 'Reloaded secret should be of type SecureString and decrypted value should be "test"' {
        $pw = Get-Secret 'pester' 'key'
        $pw | Should -BeOfType System.Security.SecureString
        (New-Object System.Management.Automation.PSCredential 0, $pw).GetNetworkCredential().Password | Should -Be "test"
    }
    It 'Reloaded secret with parameter -AsPlainText should be of type string and value should be "test"' {
        $pw = Get-Secret 'pester' 'key' -AsPlainText
        $pw | Should -BeOfType string
        $pw | Should -Be "test"
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
            #dtparam=audio=off
            $iniSample = Set-IniContent $iniSample 'dtparam=audio' 'on'
            $iniSample | Should -Not -BeLike '*dtparam=audio=off*'
            $iniSample | Should -BeLike '*dtparam=audio=on*'
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

