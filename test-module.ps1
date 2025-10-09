
Remove-Module brickBOX -Force
Import-Module $PSScriptRoot\brickBOX.psm1 -Force # Import-Module .\brickBOX.psm1 -Force
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


# 🔵 get commandlets
$cmdlts = (Get-Module brickBOX).ExportedCommands.Values | ForEach-Object {
    Get-Help $_.Name | Select-Object *, @{Name = 'Noun'; Expression = {$_.Name.Split('-')[1]}}
} | Sort-Object Component, Noun 


# 📝 Write Function-Markdown-Table
$cmdlts | Select-Object @{Name = 'Function Name'; Expression = {"[$($_.Name)](https://github.com/pagebox/brickBOX/wiki/$($_.Name))"}}, @{Name = 'Short Description'; Expression = {$_.Synopsis}}, Component | ConvertTo-Markdown


# 📝 Write Wiki
foreach ($cmdlet in $cmdlts) {
    # $cmdlet
    [array]$wiki = @()
    $wiki += "# $($cmdlet.Name)", ''
    $wiki += $cmdlet.Synopsis, ''

    $wiki += "## Syntax", ''
    $wiki += "`````` powershell"
    $wiki += ($cmdlet.syntax | Out-String).Trim()
    $wiki += "``````", ''

    $wiki += "## Description", ''
    $wiki += $cmdlet.Description.Text, ''

    $wiki += "## Examples", ''
    foreach ($itm in $cmdlet.examples.example) {
        $wiki += "### Example $($itm.title -match '^.* (?<number>\d+) .*$' | Out-Null; $matches.number)", ''
        $wiki += "`````` powershell"
        $wiki += "$($itm.introduction.Text) $($itm.code)"
        $wiki += "``````"
        
        if (($itm.remarks | Out-String) -notmatch '^\s*$') {
            $wiki += "``````"
            $wiki += $($itm.remarks | Out-String).trim()
            $wiki += "``````"
        }
        $wiki += ''
    }

    $wiki += "## Parameters", ''
    $wiki += [string]::Join("`r`n", (($t.parameters | Out-String).split("`r`n") | ForEach-Object {
        [string]$s = $_ 
        $s = $s -replace '^\W+$',''         # remove whitespaces
        $s = $s -replace '^ +-','### '      # replace leading '- ' with '### '
        $s = $s -replace '^ +<','### \<'    # replace leading '<' with '### \<'

        if ($s -match '^( +)([A-Za-z]+).*  .+$') { # convert parameter description
            $s = $s -replace '^ +','- '
            $s = $s -replace ' {2,}',': '
        }
        $s = $s -replace '^ +',''           # remove leading whitespace
        return $s
    })).trim(), ''

    $wiki += "## Return Value", ''
    $wiki += ($cmdlet.returnValues | Out-String).trim(), ''

    [string]::Join("`r`n", $wiki) | Set-Content "..\brickBOX.wiki\$($cmdlet.Name).md"
}


