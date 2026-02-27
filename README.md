# Get-UnsetPhoneUsers (Microsoft Graph / Entra ID)

PowerShell script to audit Microsoft Entra ID users who have **no phone numbers** configured.
Exports a CSV report using Microsoft Graph **app-only** authentication (Client Credentials Flow).

## What it checks
A user is reported when:
- `businessPhones` is empty **and**
- `mobilePhone` is null

## Output
Generates: `Auditoria_Usuarios_Sin_Telefono.csv`

Columns:
- `displayName`
- `userPrincipalName`
- `Status` (`Missing Phone`)

## Prerequisites
1) An App Registration in Microsoft Entra ID  
2) Microsoft Graph **Application** permission:
- `User.Read.All`
3) Admin consent granted

## Security (Read this)
- **Never** commit secrets to GitHub.
- Use environment variables for local runs.
- For production, prefer **Azure Key Vault** + **Managed Identity**.

## Configure environment variables
In PowerShell:

```powershell
$env:TENANT_ID="YOUR_TENANT_ID"
$env:CLIENT_ID="YOUR_CLIENT_ID"
$env:CLIENT_SECRET="YOUR_CLIENT_SECRET_VALUE"

## Enterprise Features
- **Pagination Support**: The script automatically follows `@odata.nextLink` to fetch all users in the tenant, bypassing the default 100-user limit.
- **Environment Variable Auth**: No hardcoded secrets. Uses `Assert-EnvVar` to ensure the environment is correctly configured before execution.

## Roadmap / Future Improvements
- [ ] **Throttling Handling**: Implement retry logic for `HTTP 429` (Too Many Requests) responses.
- [ ] **Advanced Filtering**: Use `$filter` on the server-side to reduce data transfer (requires `ConsistencyLevel: eventual`).
- [ ] **Azure Key Vault Integration**: Fetch secrets directly from a secure vault instead of environment variables.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
