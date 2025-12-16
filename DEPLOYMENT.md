# Deployment Guide

This guide explains how to deploy the modernized application to Azure.

## Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- .NET 8 SDK (for local development)
- Python 3.x with pip (for database operations)
- ODBC Driver 18 for SQL Server

## Quick Start

### 1. Build the Application

```bash
bash build-app.sh
```

This will:
- Restore .NET dependencies
- Build the application in Release mode
- Publish the application
- Create `app/app.zip` for deployment

### 2. Deploy to Azure

#### Option A: Basic Deployment (No AI)

```bash
bash deploy.sh
```

This deploys:
- Resource Group
- App Service (S1 SKU)
- Azure SQL Database (Basic tier)
- User Assigned Managed Identity
- Database schema and stored procedures
- Application code

#### Option B: Full Deployment with AI Chat

```bash
bash deploy-with-chat.sh
```

This deploys everything from Option A, plus:
- Azure OpenAI (GPT-4o in Sweden Central)
- Azure Cognitive Search (Basic tier)
- Role assignments for managed identity

## What Happens During Deployment

### Phase 1: Infrastructure Deployment (2-5 minutes)
1. Creates resource group (rg-appmod-demo)
2. Deploys Bicep templates
3. Creates managed identity (mid-appmodassist-16-10-32)
4. Creates App Service and App Service Plan
5. Creates Azure SQL Server with Entra ID authentication
6. Creates Northwind database
7. (If with-chat) Creates Azure OpenAI and Cognitive Search

### Phase 2: Configuration (30-60 seconds)
1. Configures App Service environment variables
2. Sets up managed identity client ID
3. Waits for SQL Server to be ready (30 seconds)
4. Adds firewall rules for current IP and Azure services
5. Waits for firewall propagation (15 seconds)

### Phase 3: Database Setup (1-3 minutes)
1. Installs Python dependencies (pyodbc, azure-identity)
2. Imports database schema from Database-Schema/database_schema.sql
3. Configures database roles for managed identity
4. Deploys stored procedures

### Phase 4: Application Deployment (1-2 minutes)
1. Deploys app.zip to App Service
2. Application starts and warms up

**Total Time:** 5-10 minutes for basic, 7-12 minutes with AI

## After Deployment

You'll see output like this:

```
==========================================
Deployment Complete!
==========================================
App Service URL: https://app-appmod-xyz123.azurewebsites.net/Index
Chat UI URL: https://app-appmod-xyz123.azurewebsites.net/Chat
API Documentation: https://app-appmod-xyz123.azurewebsites.net/swagger
Note: Navigate to /Index to view the app
```

### Available Endpoints

- **Main UI**: `/Index` - Dashboard with navigation to all features
- **Properties**: `/Properties` - View and manage properties
- **Sections**: `/Sections` - View and manage sections
- **Workbases**: `/Workbases` - View and manage workbases
- **Users**: `/Users` - View and manage users
- **Chat UI**: `/Chat` - AI-powered natural language interface
- **API Docs**: `/swagger` - Interactive API documentation

### First-Time Access

1. Navigate to the App Service URL + `/Index`
2. The app will connect to the database using managed identity
3. If there are any connection issues, you'll see detailed error messages with troubleshooting steps
4. The app will display dummy data if the database is not accessible

## Local Development

To run the application locally:

### 1. Update Configuration

Edit `app/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:YOUR-SQL-SERVER.database.windows.net;Database=Northwind;Authentication=Active Directory Default;"
  }
}
```

### 2. Authenticate

```bash
az login
```

### 3. Run the Application

```bash
cd app
dotnet run
```

### 4. Access Locally

- Main UI: https://localhost:5001/Index
- API Docs: https://localhost:5001/swagger

## Troubleshooting

### Database Connection Issues

If you see error messages about database connectivity:

1. **Check Firewall Rules**: Ensure your IP is in the SQL Server firewall rules
2. **Verify Managed Identity**: Confirm the managed identity has db_datareader, db_datawriter, and EXECUTE permissions
3. **Check Azure AD Authentication**: Verify Entra ID-only authentication is enabled

To add your IP manually:

```bash
az sql server firewall-rule create \
  --resource-group rg-appmod-demo \
  --server sql-appmod-XXXXX \
  --name "MyIP" \
  --start-ip-address YOUR_IP \
  --end-ip-address YOUR_IP
```

### AI Chat Not Working

If the chat returns "GenAI services are not deployed":

1. Deploy using `bash deploy-with-chat.sh` instead of `deploy.sh`
2. Check that Azure OpenAI endpoint is configured in App Service settings
3. Verify managed identity has "Cognitive Services OpenAI User" role

### Build Failures

If `build-app.sh` fails:

1. **Check .NET SDK**: Ensure .NET 8 SDK is installed (`dotnet --version`)
2. **Clean Build**: Delete `app/bin` and `app/obj` folders and try again
3. **Check Dependencies**: Run `dotnet restore` in the `app` directory

### Deployment Script Errors

Common issues and solutions:

- **Azure CLI not authenticated**: Run `az login`
- **Insufficient permissions**: Ensure you have Contributor role on the subscription
- **Resource name conflicts**: The deployment uses unique suffixes based on resource group ID
- **Timeout errors**: Increase wait times in the deployment scripts

## Cleanup

To remove all deployed resources:

```bash
az group delete --name rg-appmod-demo --yes --no-wait
```

⚠️ **Warning**: This permanently deletes all resources including the database!

## Security Notes

- ✅ No passwords or secrets stored in code or configuration
- ✅ Managed identity used for all Azure service authentication
- ✅ Entra ID (Azure AD) authentication for SQL Server
- ✅ HTTPS-only enforcement
- ✅ Stored procedures prevent SQL injection
- ✅ RBAC for Azure OpenAI and Cognitive Search access

## Cost Estimation

### Basic Deployment (deploy.sh)
- App Service S1: ~$73/month
- Azure SQL Basic: ~$5/month
- **Total**: ~$78/month

### Full Deployment with AI (deploy-with-chat.sh)
- App Service S1: ~$73/month
- Azure SQL Basic: ~$5/month
- Azure OpenAI (8 capacity): ~$20-200/month (usage-based)
- Cognitive Search Basic: ~$75/month
- **Total**: ~$173-353/month (depending on AI usage)

💡 **Tip**: For POC/testing, consider using Azure OpenAI pay-as-you-go pricing and delete resources when not in use.

## Next Steps

1. ✅ Deploy the application
2. ✅ Test all endpoints
3. ✅ Customize the UI to match your branding
4. ✅ Add authentication/authorization
5. ✅ Configure custom domain
6. ✅ Set up Application Insights for monitoring
7. ✅ Configure Azure DevOps or GitHub Actions for CI/CD

## Support

For issues or questions:
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for system design details
- Review deployment script output for specific error messages
- Check Azure Portal for resource status and logs
