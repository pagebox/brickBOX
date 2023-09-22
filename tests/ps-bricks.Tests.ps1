BeforeAll {
    # $PSScriptRoot
    Import-Module .\ps-bricks.psm1 -Force

}

AfterAll {
    Remove-ItemProperty HKCU:\SOFTWARE\pageBOX\Secret\test\ -Name 'key' -ErrorAction SilentlyContinue
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

