# 1. Autenticación (Usa tus variables de entorno)
$tenantID = $env:TENANT_ID
$clientID = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET

$body = @{
    client_id     = $clientID
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method Post -Body $body
$accessToken = $tokenResponse.access_token

# 2. Consulta de Auditoría (Últimos 5 cambios)
$apiUrl = "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$top=5"
$headers = @{ Authorization = "Bearer $accessToken" }

$audits = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# 3. Formateo de Alerta de Seguridad
$report = $audits.value | Select-Object `
    @{Name="Fecha"; Expression={$_.activityDateTime}}, `
    @{Name="Accion"; Expression={$_.activityDisplayName}}, `
    @{Name="IniciadoPor"; Expression={
        if ($null -ne $_.initiatedBy.user) { $_.initiatedBy.user.userPrincipalName }
        elseif ($null -ne $_.initiatedBy.app) { "APP: " + $_.initiatedBy.app.displayName }
        else { "Sistema/Desconocido" }
    }}

$report | Format-Table -AutoSize