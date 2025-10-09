function Invoke-API {
    <#
    .SYNOPSIS
        Simplifies Invoke-RestMethod calls
    .COMPONENT
        API
    .DESCRIPTION
        This function simplifies Invoke-RestMethod calls for REST APIs.
    .EXAMPLE
        PS> Invoke-API get "https://api.ipify.org?format=json"

        ip
        --
        178.194.238.xxx
    .EXAMPLE
        PS> Invoke-API post "https://httpbin.org/post" -Payload '{"Id": 12345 }'
    .EXAMPLE
        PS> $PSDefaultParameterValues = @{
            "Invoke-RestMethod:Headers"= @{
                'Accept' = "application/json"
                'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("username:pa$$word")))"
            }
            "Invoke-RestMethod:ContentType"="application/json; charset=utf-8"
        }
        "Invoke-API post "https://reqres.in/api/users" -Payload @"
            {
                "name": "Julius User",
                "job": "leader"
            }
        "@
    #>
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/pagebox/brickBOX/wiki/Invoke-API")]
    [OutputType([System.Object])]
    param(
        # POST   Create a record
        # GET    Retrieve a record
        # PUT    Modify a record. Replace the entire resource with given data (null out fields if they are not provided in the request)
        # DELETE Delete a record
        # PATCH  Update a record. Replace only specified fields
        [ValidateSet('post', 'get', 'put', 'delete', 'patch')]
        [string]$Method = 'get',
        # complete url of the API, including https
        # secondline
        [string]$Uri,
        # payload, mandatory for post, put and patch
        [string]$Payload,
        # Omits any output, but errors
        [switch]$NoOutput = $false,
        # Overwrite the $PSDefaultParameterValues for Invoke-RestMethod:Headers on this call
        [Hashtable]$Headers,
        # Overwrite the $PSDefaultParameterValues for Invoke-RestMethod:ContentType on this call
        [string]$ContentType
    )
    process {
    
    # Write-Host ($Global:PSDefaultParameterValues | Out-String)
    
        if ([string]::IsNullOrEmpty($Headers)) {
            if ([string]::IsNullOrEmpty($Global:PSDefaultParameterValues.'Invoke-RestMethod:Headers')) {
                # Write-Host "🌠 a1 "
                $Headers = @{}
            } else {
                # Write-Host "🌠 a2 " 
                $Headers = $Global:PSDefaultParameterValues.'Invoke-RestMethod:Headers'
            }
        }

        if ([string]::IsNullOrEmpty($ContentType)) {
            if ([string]::IsNullOrEmpty($Global:PSDefaultParameterValues.'Invoke-RestMethod:ContentType')) {
                # Write-Host "🌠 b1 "
                $ContentType = "application/json; charset=utf-8"
            } else {
                # Write-Host "🌠 b2 "
                $ContentType = $Global:PSDefaultParameterValues.'Invoke-RestMethod:ContentType'
            }
        }

        if ($Method -eq 'get') {
            $response = Invoke-RestMethod -Uri $Uri -Headers $Headers -ContentType $ContentType
        } else {
            $response = Invoke-RestMethod -Method $Method -Uri $Uri -Body $Payload -Headers $Headers -ContentType $ContentType
        }
        
        if (!$NoOutput) {
            if ($response.result) { return $response.result } # ServiceNOW
            else { return $response }
        }
    }
} 

