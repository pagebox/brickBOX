
#region "⚡ ScriptProcessing"

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

    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
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
    Reads and saves secure strings to hkcu in a secure way.
.DESCRIPTION
    The function becomes handy, if you need eg. passwords or api-key in your script, but you don't want to save them in the script.
.EXAMPLE
    $password = Get-Secret 'myProject' 'myPassword'
    saves the prompted password in the registry and sets $password as SecureString
#>
function Get-Secret {
    param (
        [Parameter(Mandatory = $true)][string]$projectName,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Secret = $null,
        [switch]$AsPlainText = $false,
        [switch]$Save = $false
    )
    $regKey = "HKCU:\Software\pageBOX\Secret\$projectName"
    $value = Get-ItemProperty -Path $regKey -Name $Name -ErrorAction SilentlyContinue
    if ($value) {
        $value = $value.$Name | ConvertTo-SecureString
    } else {
        if (![string]::IsNullOrEmpty($Secret)) {
            $value = ConvertTo-SecureString $Secret -AsPlainText
        } else {
            $value = Read-Host "Please enter '$Name'" -AsSecureString
        }
        if ($Save -or $Host.UI.PromptForChoice('Confirm:', 'Do you want to save password to Registry?', ('&Yes', '&No'), 0) -eq 0) {
            if (!(Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $Name -Value ($value | ConvertFrom-SecureString) -PropertyType "String" -Force | Out-Null
        }
    }

    if ($AsPlainText) { return (New-Object System.Management.Automation.PSCredential 0, $value).GetNetworkCredential().Password }
    return $value 
}
Export-ModuleMember -Function Get-Secret

#endregion


#region "⚡ FileSystemObject"

<#
.SYNOPSIS
    Add or Update key-value pairs in ini-files
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
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

            if ($line -eq '') { $ini += "$line`n"; continue } # Skip empty line
            
            # Section
            if ($line -match "^\[(?<section>.+)\]") {
                if (!$hasSet -and ($cSection -eq $section)) { $ini += "$Key=$value`n`n$line`n" } #value has not yet set, but we're going to leave matching section
                $cSection = $Matches.section
                $ini += "$line`n"; continue
            }
            if ($cSection -ne $section) { $ini += "$line`n"; continue } # Section doesn't match, skip and continue
            
            
            $isComment = $line -match '^[#;]'
            if (!$uncomment -and $isComment) { $ini += "$line`n"; continue } # Skip comments, if we don't want to uncomment

            
            # try to get key-value-pair
            if ($line -match "(?<key>.*)=(?<value>.*)") { # $line is a key-value pair
                
                $cKey = $Matches.key.Trim()
                if ($isComment) { $cKey = $cKey.Substring(1).TrimStart() }  # uncomment sKey

                if ($key.ToLower() -ne $cKey.ToLower()) { $ini += "$line`n"; continue } # key and cKey don't match, skip

                if ($line -ne "$cKey=$value" ) {
                    # changing value
                    Write-Verbose "🟠 changing: '$line' => '$cKey=$value' in section [$section]"
                    $ini += "$cKey=$value`n"
                } else { # no need to change
                    Write-Verbose "⚪ unchanged: '$line' in section [$section]"
                    $ini += "$line`n"
                }
                
                $hasSet = $true

            } else { $ini += "$line`n"; continue } # $line is no key-value-pair

        }


        if (!$hasSet) { # value has not yet set.
            if ($cSection -ne $section) { Write-Verbose "adding: section [$section]"; $ini += "`n[$section]`n" } # we were even missing the section
            Write-Verbose "🟢 adding: '$Key=$value' in section [$section]"
            $ini += "$Key=$value`n" 
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
Simplifies Invoke-RestMethod

.DESCRIPTION
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
        #[Hashtable]$Headers = $PSDefaultParameterValues["Invoke-RestMethod:Headers"],
        [Hashtable]$Headers = $(if ($null -ne $PSDefaultParameterValues) {$PSDefaultParameterValues["Invoke-RestMethod:Headers"]} else {@{}}),
        #[string]$ContentType = $PSDefaultParameterValues["Invoke-RestMethod:ContentType"]  # "application/json; charset=utf-8"
        [string]$ContentType = $(if ($null -ne $PSDefaultParameterValues) {$PSDefaultParameterValues["Invoke-RestMethod:ContentType"]})  # "application/json; charset=utf-8"
    )

    if ($Method -eq 'get') {
        $response = Invoke-RestMethod -Uri $Uri #-Headers $Headers -ContentType $ContentType
    }
    else {
        $response = Invoke-RestMethod -Method $Method -Uri $Uri -Body $Payload -Headers $Headers -ContentType $ContentType
    }
    
    # if (!$NoOutput) { $response.result }
    if (!$NoOutput) {
        if ($response.result) { $response.result } # ServiceNOW
        else { $response }
    }
}
Export-ModuleMember -Function Invoke-API

#endregion
