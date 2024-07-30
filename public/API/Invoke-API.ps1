function Invoke-API {
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
    param(
        [ValidateSet('post', 'get', 'put', 'delete', 'patch')][string]$Method = 'get',
        [string]$Uri,
        [string]$Payload,
        [switch]$NoOutput = $false,
        [Hashtable]$Headers,
        [string]$ContentType
    )

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
        if ($response.result) { $response.result } # ServiceNOW
        else { $response }
    }
}
