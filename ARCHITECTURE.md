# Azure Services Architecture Diagram

This diagram shows how the Azure services connect to each other:

```
┌─────────────────────────────────────────────────────────────────┐
│                         Azure Cloud                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Resource Group (rg-appmod-demo)               │ │
│  │                                                              │ │
│  │  ┌──────────────────────┐                                  │ │
│  │  │  User Assigned       │                                  │ │
│  │  │  Managed Identity    │◄─────────────┐                  │ │
│  │  │  (mid-appmodassist)  │              │                  │ │
│  │  └──────────────────────┘              │                  │ │
│  │           │                             │                  │ │
│  │           │ Assigned to                 │                  │ │
│  │           │                             │                  │ │
│  │           ▼                             │                  │ │
│  │  ┌──────────────────────┐              │                  │ │
│  │  │   App Service        │              │ Grants Access    │ │
│  │  │   (app-appmod-xxx)   │              │                  │ │
│  │  │                      │              │                  │ │
│  │  │  - .NET 8 Runtime    │              │                  │ │
│  │  │  - Razor Pages UI    │              │                  │ │
│  │  │  - REST APIs         │              │                  │ │
│  │  │  - Chat Interface    │              │                  │ │
│  │  └──────────────────────┘              │                  │ │
│  │           │                             │                  │ │
│  │           │ Connects via                │                  │ │
│  │           │ Managed Identity            │                  │ │
│  │           │                             │                  │ │
│  │           ▼                             │                  │ │
│  │  ┌──────────────────────┐              │                  │ │
│  │  │   Azure SQL Server   │              │                  │ │
│  │  │   (sql-appmod-xxx)   │              │                  │ │
│  │  │                      │              │                  │ │
│  │  │  - Entra ID Auth     │◄─────────────┘                  │ │
│  │  │  - Database:         │                                  │ │
│  │  │    Northwind         │                                  │ │
│  │  └──────────────────────┘                                  │ │
│  │           ▲                                                 │ │
│  │           │                                                 │ │
│  │           │ Uses Stored Procedures                         │ │
│  │           │                                                 │ │
│  │  ┌────────┴───────────────────────────────────────────┐   │ │
│  │  │             When GenAI is Deployed                  │   │ │
│  │  │                                                      │   │ │
│  │  │  ┌──────────────────────┐    ┌──────────────────┐ │   │ │
│  │  │  │  Azure OpenAI        │    │  Azure Cognitive │ │   │ │
│  │  │  │  (oai-appmod-xxx)    │    │  Search          │ │   │ │
│  │  │  │                      │    │  (srch-appmod)   │ │   │ │
│  │  │  │  - GPT-4o Model      │    │                  │ │   │ │
│  │  │  │  - Function Calling  │    │  - RAG Support   │ │   │ │
│  │  │  │  - Sweden Central    │    │                  │ │   │ │
│  │  │  └──────────────────────┘    └──────────────────┘ │   │ │
│  │  │           ▲                           ▲            │   │ │
│  │  │           │                           │            │   │ │
│  │  │           └───────────┬───────────────┘            │   │ │
│  │  │                       │                            │   │ │
│  │  │              Accessed via Managed Identity         │   │ │
│  │  │                       │                            │   │ │
│  │  │                       ▼                            │   │ │
│  │  │              ┌──────────────────┐                  │   │ │
│  │  │              │   App Service    │                  │   │ │
│  │  │              │   Chat Service   │                  │   │ │
│  │  │              └──────────────────┘                  │   │ │
│  │  └─────────────────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘

External Access:
- Users access via HTTPS: https://app-appmod-xxx.azurewebsites.net/Index
- API Documentation: https://app-appmod-xxx.azurewebsites.net/swagger
- Chat Interface: https://app-appmod-xxx.azurewebsites.net/Chat
```

## Authentication Flow

1. **User Assigned Managed Identity**: Created and assigned to App Service
2. **App Service**: Uses the managed identity to authenticate to:
   - Azure SQL Database (via Entra ID authentication)
   - Azure OpenAI (via RBAC - Cognitive Services OpenAI User role)
   - Azure Cognitive Search (via RBAC - Search Index Data Contributor role)
3. **No Secrets**: No connection strings with passwords or API keys are stored

## Data Flow

1. User accesses the web UI
2. UI makes requests to API endpoints
3. API uses stored procedures to interact with SQL Database
4. Chat UI uses function calling to invoke API operations
5. Azure OpenAI processes natural language requests
6. Results are formatted and returned to the user

## Deployment Options

- **deploy.sh**: Deploys App Service + SQL Database only (no GenAI)
- **deploy-with-chat.sh**: Deploys everything including Azure OpenAI and Cognitive Search
