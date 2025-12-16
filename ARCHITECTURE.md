# Expense Management System Architecture

## Azure Services Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User / Browser                           │
└────────────┬──────────────────────────────────┬─────────────────┘
             │                                   │
             │ HTTPS                             │ HTTPS
             │                                   │
             v                                   v
┌────────────────────────────┐      ┌──────────────────────────────┐
│     Azure App Service      │      │   Swagger UI / REST API      │
│   (.NET 8 Razor Pages)     │      │                              │
│                            │      │  /swagger                    │
│  - Managed Identity Auth   │      │  /api/expenses               │
│  - Razor Pages UI          │      │  /api/users                  │
│  - REST APIs               │      │  /api/categories             │
│  - Chat UI (/chat)         │      │  /api/chat                   │
└────────────┬───────────────┘      └──────────────────────────────┘
             │
             │ Managed Identity
             │ Authentication
             │
    ┌────────┴────────┬──────────────────────────┬────────────────┐
    │                 │                          │                │
    v                 v                          v                v
┌─────────┐   ┌──────────────┐   ┌─────────────────┐   ┌─────────────────┐
│ Azure   │   │ Azure OpenAI │   │ Azure Cognitive │   │ User-Assigned   │
│   SQL   │   │              │   │     Search      │   │    Managed      │
│Database │   │  GPT-4o      │   │                 │   │    Identity     │
│         │   │  Model       │   │   (for RAG)     │   │                 │
│Northwind│   │              │   │                 │   │ - SQL Roles     │
│  (LTS)  │   │swedencentral │   │   (Optional)    │   │ - OpenAI Access │
│         │   │              │   │                 │   │ - Search Access │
└─────────┘   └──────────────┘   └─────────────────┘   └─────────────────┘
```

## Component Details

### Azure App Service (S1 SKU)
- Hosts the .NET 8 ASP.NET Core Razor Pages application
- Configured with user-assigned managed identity
- Always-on enabled to avoid cold starts
- Deployed to UK South region

### Azure SQL Database (Basic Tier)
- Database: Northwind
- Entra ID-only authentication enabled (no SQL auth)
- Tables: Users, Roles, Expenses, ExpenseCategories, ExpenseStatus
- Stored procedures for all data operations
- Managed identity granted db_datareader, db_datawriter, and EXECUTE permissions

### User-Assigned Managed Identity
- Created automatically during deployment
- Assigned to App Service
- Granted database roles on Azure SQL
- Granted "Cognitive Services OpenAI User" role on Azure OpenAI
- Granted "Search Index Data Contributor" role on Cognitive Search

### Azure OpenAI (S0 SKU) - Optional
- Deployed to Sweden Central (for quota availability)
- Model: GPT-4o with capacity 8
- Used for AI Chat Assistant functionality
- Accessed via managed identity (no API keys)

### Azure Cognitive Search (Basic SKU) - Optional
- Used for RAG (Retrieval-Augmented Generation) patterns
- Accessed via managed identity
- Lowercase resource name required

## Authentication Flow

```
User Request
    ↓
App Service
    ↓
Managed Identity acquires token
    ↓
┌─────────────────────────────┐
│  For SQL:                   │
│  Token scope:               │
│  https://database.          │
│  windows.net/.default       │
└─────────────────────────────┘
    ↓
Azure SQL Database validates token
    ↓
Access Granted

```

## Data Flow

### Viewing Expenses
```
Browser → Razor Page (/Index)
              ↓
         DatabaseService
              ↓
    Stored Procedure (GetExpenses)
              ↓
         Azure SQL
              ↓
         Returns Data
              ↓
         Renders UI
```

### AI Chat Assistant
```
Browser → Chat UI (/chat)
              ↓
         POST /api/chat
              ↓
         ChatService
              ↓
    Azure OpenAI (GPT-4o)
         ↙         ↘
Function Call    Final Response
    ↓
DatabaseService
    ↓
Stored Procedures
    ↓
Azure SQL
    ↓
Returns Data to OpenAI
    ↓
Natural Language Response
    ↓
Displayed in Chat UI
```

## Deployment Options

### Basic Deployment (deploy.sh)
Deploys:
- Azure App Service
- Azure SQL Database
- Managed Identity
- Web Application

### Full Deployment (deploy-with-chat.sh)
Deploys everything from basic plus:
- Azure OpenAI
- Azure Cognitive Search
- Chat functionality enabled

## Security Features

1. **Entra ID-Only Authentication**: SQL Server configured to only accept Azure AD authentication
2. **Managed Identity**: No secrets or connection strings stored in code
3. **Stored Procedures**: No direct SQL in application code
4. **HTTPS Only**: All traffic encrypted
5. **Firewall Rules**: SQL Server firewall configured for Azure services and deployment IP

## Endpoints

- **Main UI**: `https://app-expensemgmt-{uniqueid}.azurewebsites.net/Index`
- **API Docs**: `https://app-expensemgmt-{uniqueid}.azurewebsites.net/swagger`
- **Chat UI**: `https://app-expensemgmt-{uniqueid}.azurewebsites.net/chat`
- **API Base**: `https://app-expensemgmt-{uniqueid}.azurewebsites.net/api`

## Cost Optimization

- **App Service**: S1 tier for production-ready performance without cold starts
- **SQL**: Basic tier suitable for development and POC
- **OpenAI**: S0 tier with minimal capacity (8)
- **Search**: Basic tier for RAG scenarios
- All services use consumption-based or low-tier SKUs for cost efficiency
