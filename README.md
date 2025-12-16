![Header image](https://github.com/DougChisholm/App-Mod-Booster/blob/main/repo-header-booster.png)

# App-Mod-Booster
A project to show how GitHub coding agent can turn screenshots of a legacy app into a working proof-of-concept for a cloud native Azure replacement if the legacy database schema is also provided.

## Steps to modernise an app:

1. Fork this repo 
2. In new repo replace the screenshots and sql schema (or keep the samples)
3. Open the coding agent and use app-mod-booster agent telling it "modernise my app"
4. When the app code is generated (can take up to 30 minutes) there will be a pull request to approve.
5. Now you can use codespaces to deploy the app to azure (or open VS Code and clone the repo locally - you will need to install some tools locally or use the devcontainer)
6. Open terminal and type "az login" to set subscription/context
7. Build the application: `bash build-app.sh`
8. Then type `bash deploy.sh` to deploy the app and db or `bash deploy-with-chat.sh` to deploy the app, db and chat UI.

## What Gets Deployed

### Option 1: Basic Deployment (`deploy.sh`)
- **Azure App Service** (S1 SKU) - Hosts the .NET 8 web application
- **Azure SQL Database** (Basic tier) - Northwind database with Entra ID authentication
- **User Assigned Managed Identity** - For secure authentication between services
- **Firewall Rules** - Configured for Azure services and deployment IP

### Option 2: Full Deployment with AI (`deploy-with-chat.sh`)
- Everything from Option 1, plus:
- **Azure OpenAI** (Sweden Central) - GPT-4o model with function calling
- **Azure Cognitive Search** (Basic tier) - For RAG pattern support
- **Role Assignments** - Managed identity access to OpenAI and Search

## Application Features

- **Modern ASP.NET Core 8** Razor Pages UI with clean, modern design
- **REST API** with Swagger documentation at `/swagger`
- **Database Operations** via stored procedures (no direct SQL in code)
- **Error Handling** with dummy data fallback and detailed error messages
- **Managed Identity Authentication** to Azure SQL and Azure OpenAI (no secrets!)
- **AI Chat Interface** at `/Chat` for natural language database queries
- **Function Calling** integration for AI to execute real database operations

## Accessing the Application

After deployment completes, you'll see the URLs:
- **Main UI**: `https://app-appmod-xxx.azurewebsites.net/Index`
- **API Docs**: `https://app-appmod-xxx.azurewebsites.net/swagger`
- **Chat UI**: `https://app-appmod-xxx.azurewebsites.net/Chat`

## Running Locally

To run the application locally:
1. Update `app/appsettings.json` connection string to use `Authentication=Active Directory Default`
2. Run `az login` to authenticate
3. Navigate to the `app` directory
4. Run `dotnet run`
5. Open browser to `https://localhost:5001/Index`

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture diagram and data flow.

## Security Features

- ✅ Entra ID (Azure AD) authentication for SQL Server
- ✅ No SQL passwords stored anywhere
- ✅ Managed Identity for all service-to-service communication
- ✅ RBAC for Azure OpenAI and Cognitive Search access
- ✅ Stored procedures prevent SQL injection
- ✅ HTTPS only enforcement

## Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide with troubleshooting
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and data flow diagrams

## Project Structure

```
.
├── infra/                      # Azure Bicep infrastructure as code
│   ├── main.bicep             # Main deployment template
│   └── modules/               # Reusable Bicep modules
│       ├── app-service.bicep  # App Service and Managed Identity
│       ├── azure-sql.bicep    # SQL Server and Database
│       └── genai.bicep        # Azure OpenAI and Cognitive Search
├── app/                       # .NET 8 Application
│   ├── Controllers/           # REST API controllers
│   ├── Models/                # Data models
│   ├── Pages/                 # Razor Pages UI
│   ├── Services/              # Business logic services
│   ├── wwwroot/               # Static files (CSS, JS)
│   └── app.zip                # Pre-built deployment package
├── Database-Schema/           # SQL database schema
├── Legacy-Screenshots/        # Original app screenshots for reference
├── deploy.sh                  # Basic deployment script
├── deploy-with-chat.sh        # Full deployment with AI
├── build-app.sh               # Application build script
├── run-sql.py                 # Schema import script
├── run-sql-dbrole.py          # Database role configuration
├── run-sql-stored-procs.py    # Stored procedure deployment
├── script.sql                 # Managed identity role assignment
└── stored-procedures.sql      # All database stored procedures
```

## Technology Stack

- **Backend**: ASP.NET Core 8.0 (LTS), C# 12
- **Database**: Azure SQL Database with Entra ID authentication
- **AI**: Azure OpenAI (GPT-4o) with function calling
- **Search**: Azure Cognitive Search for RAG
- **Authentication**: Managed Identity (no secrets!)
- **Infrastructure**: Azure Bicep
- **Deployment**: Bash + Azure CLI + Python

## Contributing

This project follows the App Modernization Booster pattern. To contribute:

1. Review the prompts in the `prompts/` directory
2. Update the relevant prompt files with improvements
3. Test changes by forking the repo and running the agent
4. Submit a pull request with your enhancements

Supporting slides for Microsoft Employees:
[Here](<https://microsofteur-my.sharepoint.com/:p:/g/personal/dchisholm_microsoft_com/IQAY41LQ12fjSIfFz3ha4hfFAZc7JQQuWaOrF7ObgxRK6f4?e=p6arJs>)
