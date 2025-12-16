# Azure Services Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Azure Resource Group                             │
│                          (rg-appmod-demo)                                │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                    User-Assigned Managed Identity               │    │
│  │                     (mid-AppModAssist-*)                        │    │
│  └────────────────┬────────────────────────────┬──────────────────┘    │
│                   │                             │                        │
│                   │ Assigned to                 │ Granted Roles         │
│                   ▼                             ▼                        │
│  ┌──────────────────────────────┐    ┌──────────────────────────────┐  │
│  │     Azure App Service         │    │      Azure SQL Database      │  │
│  │    (app-appmod-*)             │    │   (sqlserver-appmod-*)       │  │
│  │                               │    │                               │  │
│  │  - .NET 8 Razor Pages         │◄───┤  - Entra ID Only Auth        │  │
│  │  - REST API Controllers       │    │  - HSIR3 Schema               │  │
│  │  - Swagger/OpenAPI            │    │  - Stored Procedures          │  │
│  │  - Chat UI                    │    │  - Managed Identity Access    │  │
│  │                               │    │  - Basic Tier                 │  │
│  │  Entities:                    │    │                               │  │
│  │  - Departments (Divisions)    │    │  Tables:                      │  │
│  │  - Sections                   │    │  - Department                 │  │
│  │  - Properties                 │    │  - Section                    │  │
│  │  - Workbases                  │    │  - Property                   │  │
│  │  - Users                      │    │  - Workbase                   │  │
│  │                               │    │  - User                       │  │
│  └───────────┬───────────────────┘    └──────────────────────────────┘  │
│              │                                                            │
│              │ (Optional - deploy-with-chat.sh)                          │
│              ▼                                                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │              GenAI Resources (Conditional Deployment)             │   │
│  │                                                                   │   │
│  │  ┌──────────────────────────┐    ┌──────────────────────────┐   │   │
│  │  │   Azure OpenAI Service    │    │  Azure Cognitive Search  │   │   │
│  │  │  (aoai-appmod-*)          │    │   (search-appmod-*)      │   │   │
│  │  │                           │    │                          │   │   │
│  │  │  - GPT-4o Model           │    │  - RAG Document Search   │   │   │
│  │  │  - Sweden Central Region  │    │  - S0 SKU                │   │   │
│  │  │  - Function Calling       │    │                          │   │   │
│  │  │  - Chat Integration       │    │                          │   │   │
│  │  │  - Managed Identity Auth  │    │  - Managed Identity Auth │   │   │
│  │  └──────────────────────────┘    └──────────────────────────┘   │   │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

                                    │
                                    │ HTTPS
                                    ▼
                            ┌───────────────┐
                            │     Users     │
                            └───────────────┘
```

## Connection Flow

1. **User Access**:
   - Users access the App Service via HTTPS
   - Navigate to `/Index` for the main application

2. **Authentication**:
   - App Service uses User-Assigned Managed Identity
   - Managed Identity authenticates to Azure SQL Database
   - No passwords or connection strings stored
   - Entra ID (Azure AD) Only Authentication on SQL

3. **Data Access**:
   - App Service connects to SQL Database using Managed Identity
   - All database operations use stored procedures
   - No T-SQL in application code

4. **Chat Feature** (Optional):
   - Chat UI in App Service
   - Connects to Azure OpenAI for natural language processing
   - Uses Azure Cognitive Search for RAG (Retrieval-Augmented Generation)
   - Function calling enables database operations via chat
   - Managed Identity for secure service-to-service communication

## Deployment Scripts

- **deploy.sh**: Deploys core infrastructure (App Service, SQL, Managed Identity)
- **deploy-with-chat.sh**: Deploys everything including GenAI resources

## Security Features

- ✅ User-Assigned Managed Identity for authentication
- ✅ Entra ID (Azure AD) Only Authentication on SQL Server
- ✅ No SQL authentication allowed (policy requirement)
- ✅ Firewall rules for Azure services and deployment IP
- ✅ Database roles: db_datareader, db_datawriter, EXECUTE permissions
- ✅ All secrets managed through Azure platform
- ✅ HTTPS encryption for all connections

## Key Components

### Application Service (S1 SKU)
- No cold start delays
- Modern Razor Pages UI
- REST API with Swagger documentation
- Error handling with detailed messages

### Database (Basic Tier)
- Development/POC appropriate tier
- Stored procedures for all CRUD operations
- Legacy HSIR3 schema support
- Section name uniqueness validation (case-insensitive)

### GenAI (Optional)
- GPT-4o model for advanced AI capabilities
- Capacity: 8 units
- Function calling for database integration
- Sweden Central region for quota availability
