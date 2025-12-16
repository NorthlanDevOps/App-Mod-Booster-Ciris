# Deployment Guide

This guide explains how to deploy the modernized Expense Management System to Azure.

## Prerequisites

1. **Azure CLI**: Install from https://docs.microsoft.com/cli/azure/install-azure-cli
2. **Azure Subscription**: Active Azure subscription with permissions to create resources
3. **.NET 8 SDK**: For building the application (installed automatically in deployment)
4. **Python 3**: For database scripts (usually pre-installed)
5. **Required Python packages**: `pyodbc`, `azure-identity` (installed automatically)

## Quick Start

### Option 1: Basic Deployment (App + Database)

Deploy the expense management app with Azure SQL Database:

```bash
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Run the deployment script
bash deploy.sh
```

**Deployment Time**: ~10-15 minutes

**What Gets Deployed**:
- Azure App Service (S1 SKU)
- Azure SQL Database (Basic tier)
- User-Assigned Managed Identity
- Database schema, roles, and stored procedures
- .NET 8 web application

### Option 2: Full Deployment with AI Chat (App + Database + GenAI)

Deploy everything including Azure OpenAI for AI chat assistant:

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Run the deployment script with GenAI
bash deploy-with-chat.sh
```

**Deployment Time**: ~15-20 minutes

**What Gets Deployed**:
- Everything from Option 1, plus:
- Azure OpenAI (GPT-4o model in Sweden Central)
- Azure Cognitive Search (Basic tier)
- AI Chat Assistant functionality

## Accessing the Application

After deployment completes, you'll see output like:

```
App URL: https://app-expensemgmt-XXXXX.azurewebsites.net/Index
API Documentation: https://app-expensemgmt-XXXXX.azurewebsites.net/swagger
AI Chat Assistant: https://app-expensemgmt-XXXXX.azurewebsites.net/chat
```

**Important**: Navigate to `/Index` (not just the root URL)

## Features

### Main UI (`/Index`)
- View all expenses with filtering by user, status, and category
- Summary cards showing expense totals by status
- Create, edit, and submit expenses
- Approve/reject expenses (for managers)
- Modern Bootstrap 5 interface

### API Documentation (`/swagger`)
- Interactive Swagger UI
- Test all REST API endpoints
- View request/response schemas
- Try out API calls directly

### AI Chat Assistant (`/chat`) - GenAI deployment only
- Natural language queries about expenses
- AI can retrieve expense data using function calling
- Ask questions like:
  - "Show me all submitted expenses"
  - "What's my expense summary?"
  - "List all users"
  - "Show me travel expenses for Alice"

## Configuration

### Database Connection
The app uses managed identity to connect to Azure SQL. Connection details are configured automatically during deployment via App Service settings:
- `Database__Server`: SQL Server FQDN
- `Database__Database`: Database name (Northwind)
- `ManagedIdentityClientId`: Managed identity client ID

### GenAI Configuration (deploy-with-chat.sh only)
OpenAI configuration is set automatically:
- `OpenAI__Endpoint`: Azure OpenAI endpoint
- `OpenAI__DeploymentName`: Model deployment name (gpt-4o)
- `AZURE_CLIENT_ID`: Managed identity for OpenAI access

### Local Development

To run the app locally:

1. Update `app/appsettings.Development.json`:
```json
{
  "Database": {
    "Server": "YOUR_SQL_SERVER.database.windows.net",
    "Database": "Northwind"
  }
}
```

2. Login with Azure CLI (for managed identity):
```bash
az login
```

3. Run the application:
```bash
cd app
dotnet run
```

The app will use `Authentication=Active Directory Default` which will use your Azure CLI credentials.

## Troubleshooting

### Issue: "Unable to connect to the database"

**Solution**: This typically indicates a managed identity issue. The app will display dummy data and show a detailed error message explaining the problem. Check:

1. Managed identity is assigned to App Service
2. Managed identity has db_datareader, db_datawriter, and EXECUTE permissions
3. SQL Server allows Azure services access
4. Your IP is whitelisted if connecting from outside Azure

### Issue: "GenAI services not configured"

**Solution**: You deployed with `deploy.sh` instead of `deploy-with-chat.sh`. The chat UI will show a message indicating GenAI is not configured. To enable:

1. Run `deploy-with-chat.sh` instead
2. Or deploy GenAI module separately

### Issue: "Script already ran - placeholder not found"

**Solution**: The deployment scripts modify files in-place. To re-deploy:

```bash
# Reset modified files
git restore run-sql.py run-sql-dbrole.py run-sql-stored-procs.py script.sql

# Run deployment again
bash deploy.sh
```

Or delete and recreate the resource group for a clean deployment.

## Clean Up

To remove all deployed resources:

```bash
az group delete --name rg-expensemgmt-demo --yes --no-wait
```

## Cost Estimates (UK South, Monthly)

### Basic Deployment:
- App Service (S1): ~£56
- SQL Database (Basic): ~£4
- **Total**: ~£60/month

### Full Deployment with GenAI:
- App Service (S1): ~£56
- SQL Database (Basic): ~£4
- Azure OpenAI (S0, 8 capacity): ~£0.50/1K tokens (~£10-50 depending on usage)
- Cognitive Search (Basic): ~£56
- **Total**: ~£126-166/month (depending on usage)

Note: These are estimates. Actual costs may vary based on usage and region.

## Security

- **No Secrets**: All authentication uses managed identity
- **Entra ID Only**: SQL Server configured for Azure AD authentication only
- **HTTPS Only**: All traffic encrypted
- **Stored Procedures**: No direct SQL in application code
- **Input Validation**: All stored procedures validate inputs
- **XSS Protection**: HTML escaping in chat UI

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture diagrams and component descriptions.

## Support

For issues or questions:
1. Check the error message in the UI (detailed error information is displayed)
2. Review deployment script output
3. Check Azure Portal for resource status
4. Review application logs in App Service

## Next Steps

After deployment:

1. **Explore the UI**: Navigate to `/Index` and try creating expenses
2. **Test the APIs**: Use `/swagger` to interact with REST endpoints
3. **Try AI Chat**: If deployed with GenAI, visit `/chat` and ask about expenses
4. **Customize**: Modify the code to fit your requirements
5. **Scale**: Upgrade to higher SKUs for production workloads

## References

- [Azure App Service Best Practices](https://learn.microsoft.com/en-us/azure/app-service/app-service-best-practices)
- [Azure SQL Best Practices](https://learn.microsoft.com/en-us/azure/azure-sql/database/best-practices-overview)
- [Azure OpenAI Best Practices](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/best-practices)
- [Managed Identity Best Practices](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations)
