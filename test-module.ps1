
# Remove-Module brickBOX -Force
# Import-Module $PSScriptRoot\brickBOX.psm1 -Force # Import-Module .\brickBOX.psm1 -Force
Import-Module Pester


# Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1
# Invoke-Pester -Output Detailed .\tests\brickBOX.Tests.ps1 -FullNameFilter 'Set-Secret, Get-Secret, Clear-Secret'


$config = [PesterConfiguration]@{
    Run = @{ Path = "$PSScriptRoot\tests\"}
    CodeCoverage = @{
        Enabled = $true
        Path = "$PSScriptRoot\brickBOX.psm1", "$PSScriptRoot\public", "$PSScriptRoot\private"
        RecursePaths = $true
        CoveragePercentTarget = 100
    }
    Output = @{ Verbosity = 'Detailed'}
}
Invoke-Pester -Configuration $config



$cmdlts = (get-module brickBOX).ExportedCommands.Values | ForEach-Object {
    # Write-Host $_.Name
    get-help $_.Name | Select-Object Name,@{Name = 'Description'; Expression = {$_.details.description.Text}},Component, @{Name = 'Noun'; Expression = {$_.Name.Split('-')[1]}}

} | Sort-Object Noun | Sort-Object Component | Select-Object Name,Description,Component
$cmdlts | ConvertTo-Markdown
#$cmdlts | Select-Object Name,Description | ConvertTo-Markdown



