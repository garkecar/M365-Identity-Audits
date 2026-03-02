#requires -Version 7.0
<#
.SYNOPSIS
    Monitors the latest Entra ID directory changes using Microsoft Graph (app-only).
.DESCRIPTION
    Queries /auditLogs/directoryAudits and prints the last 5 changes.
    Identifies whether actions were initiated by a Human or an Application (Service Principal).
.NOTES
    Required Application Permission: AuditLog.Read.All
    Do NOT hardcode secrets. Use environment variables:
      TENANT_ID, CLIENT_ID, CLIENT_SECRET
#>

# 0) Validate environment variables
foreach ($var in @("TENANT_ID", "CLIENT_ID", "CLIENT_SECRET")) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($var))) {
        throw "Missing environment variable '$var'. Set it before running the script."
    }
}

$tenantID     = $env:TENANT_ID
$clientID     = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET

# 1) Get access token (client credentials flow)
$body = @{
    client_id     = $clientID
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method Post -Body $body
$accessToken = $tokenResponse.access_token
if ([string]::IsNullOrWhiteSpace($accessToken)) { throw "Failed to obtain access token." }

# 2) Query directory audit logs (last 5 changes)
$apiUrl  = "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$top=5"
$headers = @{ Authorization = "Bearer $accessToken" }

$audits = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# 3) Format security alert report
$report = $audits.value | Select-Object `
    @{Name="Fecha";       Expression={$_.activityDateTime}}, `
    @{Name="Accion";      Expression={$_.activityDisplayName}}, `
    @{Name="Categoria";   Expression={$_.category}}, `
    @{Name="IniciadoPor"; Expression={
        if ($null -ne $_.initiatedBy.user) { $_.initiatedBy.user.userPrincipalName }
        elseif ($null -ne $_.initiatedBy.app) { "APP: " + $_.initiatedBy.app.displayName }
        else { "Sistema/Desconocido" }
    }}

Write-Host "`n🔍 Last $($audits.value.Count) directory changes:" -ForegroundColor Cyan
$report | Format-Table -AutoSize
