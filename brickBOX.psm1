
#region "⚡ ScriptProcessing"

<#
.SYNOPSIS
Returns $true, if script runs with administrator privileges

#>
function Test-Admin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
Export-ModuleMember -Function Test-Admin

<#
.SYNOPSIS
    Executes a PowerShell script or command with elevated rights
.EXAMPLE
    Start-Elevated notepad.exe
    Runs notepad as administrator
#>
function Start-Elevated {
    param(
        [Parameter(Mandatory)][string]$Command,
        [switch]$NoExit 
    )

    if (!(Test-Admin)) { 
        Write-Host "Script needs elevation: '$Command'" 
        $ArgumentList = [System.Collections.ArrayList]@("-NoProfile", "-ExecutionPolicy Bypass")
        if ($NoExit) { $ArgumentList.Add("-NoExit")}
        $ArgumentList.Add("&$Command")
        Start-Process -Verb RunAs -FilePath powershell.exe  -ArgumentList $ArgumentList
    }
}
Export-ModuleMember -Function Start-Elevated




<#
.SYNOPSIS
    Saves secure strings to hkcu in a secure way.
.DESCRIPTION
    The function becomes handy, if you need eg. passwords or api-key in your script, but you don't want to save them in the script.
.EXAMPLE
    $password = Set-Secret 'myProject' 'SecretName' 'myPassword'
    Saves the password in the registry as SecureString
#>
function Set-Secret {
    param (
        [Parameter(Mandatory = $true)][string]$projectName,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Secret = $null,
        [switch]$WhatIf = $false
    )
    $regKey = "HKCU:\Software\pageBOX\Secret\$projectName"

    if (![string]::IsNullOrEmpty($Secret)) {
        $value = ConvertTo-SecureString $Secret -AsPlainText
    } else {
        $value = Read-Host "Please enter '$Name'" -AsSecureString
    }

    if (!$WhatIf) {
        if (!(Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
        New-ItemProperty -Path $regKey -Name $Name -Value ($value | ConvertFrom-SecureString) -PropertyType "String" -Force | Out-Null
    }
}
Export-ModuleMember -Function Set-Secret



<#
.SYNOPSIS
    Reads secure strings from hkcu.
.DESCRIPTION
    The function becomes handy, if you need eg. passwords or api-key in your script, but you don't want to save them in the script.
.EXAMPLE
    $password = Get-Secret 'myProject' 'myPassword'
    Gets the password earlier saved from the registry and sets $password as SecureString
#>
function Get-Secret {
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$projectName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Name,
        [switch]$AsPlainText = $false
    )
    if ((Get-ItemProperty "HKCU:\SOFTWARE\pageBOX\Secret\$projectName\" -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains $Name) {
        $value = (Get-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\$projectName" -Name $Name -ErrorAction SilentlyContinue).$Name | ConvertTo-SecureString
    } else {
        throw "$Name not found in $projectName"
    }

    if ($AsPlainText) { return (New-Object System.Management.Automation.PSCredential 0, $value).GetNetworkCredential().Password }
    return $value 
}
Export-ModuleMember -Function Get-Secret


<#
.SYNOPSIS
    Removes secure strings from hkcu.
.EXAMPLE
    Clear-Secret 'myProject' 'myPassword'
    Removes the 'myPassword' secret form the registry
.EXAMPLE
    Clear-Secret 'myProject'
    Removes the whole project 'myProject' with all its secret form the registry
#>
function Clear-Secret {
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$projectName,
        [string]$Name = ''
    )
    if ($Name -eq '') {
        Remove-Item "HKCU:\SOFTWARE\pageBOX\Secret\$projectName\" -ErrorAction SilentlyContinue
    } else {
        Remove-ItemProperty -Path "HKCU:\Software\pageBOX\Secret\$projectName" -Name $Name -ErrorAction SilentlyContinue
    }
}
Export-ModuleMember -Function Clear-Secret

#endregion


#region "⚡ FileSystemObject"

<#
.SYNOPSIS
    Add or Update key-value pairs in ini-files
.EXAMPLE
    $payload = Set-IniContent $payload 'color' 'red' 
    sets the color=red in an ini-like content of $payload.
#>
function Set-IniContent {
    param (
        [Parameter(mandatory=$true)][System.Array]$payload,
        [Parameter(mandatory=$true)][string]$key,
        [Parameter(mandatory=$true)][string]$value,
        [Parameter()][string]$section = "",
        [switch]$uncomment = $false
    )
    
    Process{
        [String]$ini = ""
        [String]$cSection = "" # Current Section
        [bool]$hasSet = $false

        foreach ($line in $payload.Split("`n")) { 
            $line = $line.Replace("`r","") # remove CR

            if ($line -eq "") { $ini += "$line`r`n"; continue } # Skip empty line
            
            # Section
            if ($line -match "^\[(?<section>.+)\]") {
                if (!$hasSet -and ($cSection -eq $section)) { $ini += "$Key=$value`r`n`r`n$line`r`n" } #value has not yet set, but we're going to leave matching section
                $cSection = $Matches.section
                $ini += "$line`r`n"; continue
            }
            if ($cSection -ne $section) { $ini += "$line`r`n"; continue } # Section doesn't match, skip and continue
            
            
            $isComment = $line -match '^[#;]'
            if (!$uncomment -and $isComment) { $ini += "$line`r`n"; continue } # Skip comments, if we don't want to uncomment

            
            # try to get key-value-pair
            if ($line -match "(?<key>.*)=(?<value>.*)") { # $line is a key-value pair
                
                $cKey = $Matches.key.Trim()
                if ($isComment) { $cKey = $cKey.Substring(1).TrimStart() }  # uncomment sKey

                if ($key.ToLower() -ne $cKey.ToLower()) { $ini += "$line`r`n"; continue } # key and cKey don't match, skip

                if ($line -ne "$cKey=$value" ) {
                    # changing value
                    Write-Verbose "🟠 changing: '$line' => '$cKey=$value' in section [$section]"
                    $ini += "$cKey=$value`r`n"
                } else { # no need to change
                    Write-Verbose "⚪ unchanged: '$line' in section [$section]"
                    $ini += "$line`r`n"
                }
                
                $hasSet = $true

            } else { $ini += "$line`r`n"; continue } # $line is no key-value-pair

        }


        if (!$hasSet) { # value has not yet set.
            if ($cSection -ne $section) { Write-Verbose "adding: section [$section]"; $ini += "`r`n[$section]`r`n" } # we were even missing the section
            Write-Verbose "🟢 adding: '$Key=$value' in section [$section]"
            $ini += "$Key=$value`r`n" 
        } 


        # return (Get-Content $file) -replace $regex, 'https://newurl.com' #| Set-Content $file
        return $ini.Substring(0,$ini.Length-1)
    }
}
Export-ModuleMember -Function Set-IniContent

#endregion


#region "⚡ API"

<#
.SYNOPSIS
    Creates the content of the value for the 'Authorization' Property.
.EXAMPLE
    $PSDefaultParameterValues = @{
        "Invoke-RestMethod:Headers"= @{
            'Authorization' = Get-BasicAuthForHeader -username 'username' -password (ConvertTo-SecureString "password" -AsPlainText -Force)
        }
    }
#>
function Get-BasicAuthForHeader {
    param (
        [Parameter(Mandatory=$true)][string]$username,
        [Parameter(Mandatory=$true)][SecureString]$password
    )
    return "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username`:$((New-Object System.Management.Automation.PSCredential 0, $password).GetNetworkCredential().Password)")))"
}
Export-ModuleMember -Function Get-BasicAuthForHeader

<#
.SYNOPSIS
Simplifies Invoke-RestMethod

.PARAMETER Method
POST   Create a record
GET    Retrieve a record
PUT    Modify a record. Replace the entire resource with given data (null out fields if they are not provided in the request)
DELETE Delete a record
PATCH  Update a record. Replace only specified fields

.PARAMETER Uri
complete url of the API, including https

.PARAMETER Payload
payload, mandatory for post, put and patch

.PARAMETER NoOutput
Omits any output, but errors

.PARAMETER Headers
Overwrite the $PSDefaultParameterValues for Invoke-RestMethod:Headers on this call

.PARAMETER ContentType
Overwrite the $PSDefaultParameterValues for Invoke-RestMethod:ContentType on this call

.EXAMPLE
Invoke-API get "https://api.ipify.org?format=json"

.EXAMPLE
Invoke-API post "https://httpbin.org/post" -Payload '{"Id": 12345 }'

.EXAMPLE
$PSDefaultParameterValues = @{
    "Invoke-RestMethod:Headers"= @{
        'Accept' = "application/json"
        'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("username:pa$$word")))"
    }
    "Invoke-RestMethod:ContentType"="application/json; charset=utf-8"
}

Invoke-API post "https://reqres.in/api/users" -Payload @"
    {
        "name": "Julius User",
        "job": "leader"
    }
"@

#>
function Invoke-API {
    param(
        [ValidateSet('post', 'get', 'put', 'delete', 'patch')][string]$Method = 'get',
        [string]$Uri,
        [string]$Payload,
        [switch]$NoOutput = $false,
        [Hashtable]$Headers = $(if ($null -ne $Global:PSDefaultParameterValues) {$Global:PSDefaultParameterValues["Invoke-RestMethod:Headers"]} else {@{}}),
        [string]$ContentType = $(if ($null -ne $Global:PSDefaultParameterValues) {$Global:PSDefaultParameterValues["Invoke-RestMethod:ContentType"]})  # "application/json; charset=utf-8"
    )

    if ($Method -eq 'get') {
        $response = Invoke-RestMethod -Uri $Uri -Headers $Headers -ContentType $ContentType
    } else {
        $response = Invoke-RestMethod -Method $Method -Uri $Uri -Body $Payload -Headers $Headers -ContentType $ContentType
    }
    
    if (!$NoOutput) {
        if ($response.result) { $response.result } # ServiceNOW
        else { $response }
    }
}
Export-ModuleMember -Function Invoke-API

#endregion
