# M365 Identity Audits & Security Monitoring

Collection of professional PowerShell scripts to audit, monitor, and secure Microsoft Entra ID (Azure AD) using the Microsoft Graph API.

##  Overview
This repository contains automation tools designed for Cloud Security Engineers and M365 Administrators. All scripts use the OAuth 2.0 Client Credentials Flow (App-only authentication) for secure, unattended execution.

---

##  Scripts Included

### 1. Get-UnsetPhoneUsers.ps1
Purpose: Identifies users with missing contact information to improve identity security and MFA readiness.
- Permissions: `User.Read.All` (Application).
- Logic: Reports users where `businessPhones` is empty AND `mobilePhone` is null.
- Output: Generates `Auditoria_Usuarios_Sin_Telefono.csv`.
- Enterprise Feature: Full Pagination Support using `@odata.nextLink` to handle tenants of any size.

### 2. Monitor-DirectoryChanges.ps1
Purpose: Real-time monitoring of the last 5 directory changes (Users, Groups, Apps).
- Permissions: `AuditLog.Read.All` (Application).
- Security Value: Differentiates between changes made by a Human User vs. an Application (Service Principal).
- Use Case: Detecting unauthorized privilege escalation or automated backdoors.

---

##  Prerequisites & Setup

### 1. App Registration
To run these scripts, you must register an application in your Microsoft Entra admin center:
1. Go to App Registrations > New Registration.
2. Add the required Application Permissions (not Delegated):
   - `User.Read.All`
   - `AuditLog.Read.All`
3. Click "Grant admin consent" for your tenant.
4. Create a Client Secret (Save the value securely).

### 2. Environment Variables
Never hardcode secrets. These scripts are designed to fetch credentials from your local environment:

```powershell
$env:TENANT_ID="YOUR_TENANT_ID"
$env:CLIENT_ID="YOUR_CLIENT_ID"
$env:CLIENT_SECRET="YOUR_CLIENT_SECRET_VALUE"
```
##  Security Best Practices
- Least Privilege: Only grant the specific permissions required for each script.
- Secret Management: For production environments, it is highly recommended to use Azure Key Vault and Managed Identities instead of environment variables.
- Audit Logs: Regularly monitor who is using the App Registration credentials.

## Roadmap / Future Improvements
- Throttling Handling: Implement retry logic for `HTTP 429` (Too Many Requests).
- Azure Automation: Integration with Azure Automation Accounts for scheduled runs.
- Teams/Slack Alerts: Send real-time notifications when a critical directory change is detected.
- Advanced Filtering: Server-side `$filter` implementation to optimize data transfer.

##  License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
