#requires -Version 7.0
<#
.SYNOPSIS
    Audits Entra ID users missing phone numbers using Microsoft Graph (app-only).
.DESCRIPTION
    Uses client credentials flow to call Microsoft Graph /users and exports a CSV
    of users where businessPhones is empty AND mobilePhone is null.
.NOTES
    Do NOT hardcode secrets. Use environment variables:
      TENANT_ID, CLIENT_ID, CLIENT_SECRET
#>

function Assert-EnvVar {
    param([Parameter(Mandatory)][string]$Name)
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing environment variable '$Name'. Set it before running the script."
    }
    return $value
}

$tenantID     = Assert-EnvVar -Name "TENANT_ID"
$clientID     = Assert-EnvVar -Name "CLIENT_ID"
$clientSecret = Assert-EnvVar -Name "CLIENT_SECRET"

# 1) Get access token (client credentials)
$tokenBody = @{
    client_id     = $clientID
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Body $tokenBody
$accessToken = $tokenResponse.access_token
if ([string]::IsNullOrWhiteSpace($accessToken)) { throw "Failed to obtain access token." }

$headers = @{
    Authorization = "Bearer $accessToken"
}

# 2) Query users (pagination)
$apiUrl = "https://graph.microsoft.com/v1.0/users?`$select=displayName,userPrincipalName,businessPhones,mobilePhone&`$top=999"

$users = New-Object System.Collections.Generic.List[object]

while ($null -ne $apiUrl) {
    $response = Invoke-RestMethod -Method Get -Uri $apiUrl -Headers $headers
    foreach ($u in @($response.value)) { [void]$users.Add($u) }
    $apiUrl = $response.'@odata.nextLink'
}

Write-Host "Fetched users: $($users.Count)"

# 3) Audit: missing phone
$report = $users | Where-Object {
    (($_.businessPhones | Measure-Object).Count -eq 0) -and ($null -eq $_.mobilePhone)
} | Select-Object displayName, userPrincipalName, @{Name="Status";Expression={"Missing Phone"}}

# 4) Export
$outFile = "Auditoria_Usuarios_Sin_Telefono.csv"
$report | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8


Write-Host "OK. Users analyzed: $($users.Count). Missing phone: $($report.Count). Output: $outFile"

