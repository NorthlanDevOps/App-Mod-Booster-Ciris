#!/bin/bash
set -e

echo "=================================="
echo "Expense Management System Deployment (with GenAI)"
echo "=================================="
echo ""

# Variables
RESOURCE_GROUP="rg-expensemgmt-demo"
LOCATION="uksouth"
ADMIN_EMAIL=$(az account show --query user.name -o tsv)
ADMIN_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

echo "Using admin email: $ADMIN_EMAIL"
echo "Using admin object ID: $ADMIN_OBJECT_ID"
echo ""

# Create resource group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION --output none

echo "Waiting 30 seconds for resource group to be ready..."
sleep 30

# Deploy infrastructure with GenAI
echo "Deploying Azure infrastructure (App Service, SQL Database, Azure OpenAI, Cognitive Search)..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/main.bicep \
  --parameters adminObjectId=$ADMIN_OBJECT_ID adminLogin=$ADMIN_EMAIL deployGenAI=true \
  --query 'properties.outputs' \
  -o json)

echo "Deployment completed!"
echo ""

# Extract outputs
APP_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.appServiceName.value')
APP_URL=$(echo $DEPLOYMENT_OUTPUT | jq -r '.appServiceUrl.value')
SQL_SERVER_FQDN=$(echo $DEPLOYMENT_OUTPUT | jq -r '.sqlServerFqdn.value')
DATABASE_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.databaseName.value')
MANAGED_IDENTITY_CLIENT_ID=$(echo $DEPLOYMENT_OUTPUT | jq -r '.managedIdentityClientId.value')
MANAGED_IDENTITY_NAME="mid-$(echo $DEPLOYMENT_OUTPUT | jq -r '.appServiceName.value' | sed 's/app-//')"
OPENAI_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.openAIEndpoint.value')
OPENAI_MODEL_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.openAIModelName.value')
SEARCH_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.searchEndpoint.value')

echo "Deployed resources:"
echo "  App Service: $APP_NAME"
echo "  App URL: $APP_URL"
echo "  SQL Server: $SQL_SERVER_FQDN"
echo "  Database: $DATABASE_NAME"
echo "  Managed Identity Client ID: $MANAGED_IDENTITY_CLIENT_ID"
echo "  OpenAI Endpoint: $OPENAI_ENDPOINT"
echo "  OpenAI Model: $OPENAI_MODEL_NAME"
echo "  Search Endpoint: $SEARCH_ENDPOINT"
echo ""

# Configure App Service settings including GenAI settings
echo "Configuring App Service settings..."
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    "Database__Server=$SQL_SERVER_FQDN" \
    "Database__Database=$DATABASE_NAME" \
    "ManagedIdentityClientId=$MANAGED_IDENTITY_CLIENT_ID" \
    "AZURE_CLIENT_ID=$MANAGED_IDENTITY_CLIENT_ID" \
    "OpenAI__Endpoint=$OPENAI_ENDPOINT" \
    "OpenAI__DeploymentName=$OPENAI_MODEL_NAME" \
    "Search__Endpoint=$SEARCH_ENDPOINT" \
  --output none

echo "Waiting 30 seconds for SQL Server to be fully ready..."
sleep 30

# Add current IP to SQL firewall
echo "Adding current IP to SQL firewall..."
MY_IP=$(curl -s https://api.ipify.org)
SQL_SERVER_NAME=$(echo $SQL_SERVER_FQDN | cut -d'.' -f1)

# Allow Azure services access
echo "Allowing Azure services access to SQL Server..."
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name "AllowAllAzureIPs" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output none

# Add deployment IP
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name "AllowDeploymentIP" \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP \
  --output none

echo "Waiting 15 seconds for firewall rules to propagate..."
sleep 15

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --quiet pyodbc azure-identity

# Update Python scripts with server and database names
echo "Updating Python scripts..."
sed -i.bak "s/SERVER = \"example.database.windows.net\"/SERVER = \"$SQL_SERVER_FQDN\"/g" run-sql.py && rm -f run-sql.py.bak
sed -i.bak "s/DATABASE = \"Northwind\"/DATABASE = \"$DATABASE_NAME\"/g" run-sql.py && rm -f run-sql.py.bak

sed -i.bak "s/SERVER = \"example.database.windows.net\"/SERVER = \"$SQL_SERVER_FQDN\"/g" run-sql-dbrole.py && rm -f run-sql-dbrole.py.bak
sed -i.bak "s/DATABASE = \"Northwind\"/DATABASE = \"$DATABASE_NAME\"/g" run-sql-dbrole.py && rm -f run-sql-dbrole.py.bak

sed -i.bak "s/SERVER = \"example.database.windows.net\"/SERVER = \"$SQL_SERVER_FQDN\"/g" run-sql-stored-procs.py && rm -f run-sql-stored-procs.py.bak
sed -i.bak "s/DATABASE = \"Northwind\"/DATABASE = \"$DATABASE_NAME\"/g" run-sql-stored-procs.py && rm -f run-sql-stored-procs.py.bak

# Update script.sql with managed identity name
# Note: This modifies files in-place. For re-deployment, delete and recreate the resource group
# or run 'git restore' to reset the files to their original state
sed -i.bak "s/MANAGED-IDENTITY-NAME/$MANAGED_IDENTITY_NAME/g" script.sql && rm -f script.sql.bak

# Import database schema
echo "Importing database schema..."
python3 run-sql.py

echo "Waiting 15 seconds before configuring database roles..."
sleep 15

# Configure database roles for managed identity
echo "Configuring database roles for managed identity..."
python3 run-sql-dbrole.py

echo "Waiting 15 seconds before creating stored procedures..."
sleep 15

# Create stored procedures
echo "Creating stored procedures..."
python3 run-sql-stored-procs.py

# Build and publish the app
echo "Building the .NET application..."
cd app
dotnet publish -c Release -o ./publish

# Create zip file for deployment (root level, not in subdirectory)
echo "Creating deployment package..."
cd publish
zip -r ../app.zip . > /dev/null
cd ..

# Deploy app to Azure
echo "Deploying application to Azure App Service..."
az webapp deploy \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --src-path ./app.zip \
  --type zip

cd ..

echo ""
echo "=================================="
echo "Deployment Complete!"
echo "=================================="
echo ""
echo "App URL: $APP_URL/Index"
echo "API Documentation: $APP_URL/swagger"
echo "AI Chat Assistant: $APP_URL/chat"
echo ""
echo "IMPORTANT: Navigate to $APP_URL/Index (not just the root URL)"
echo ""
echo "GenAI Features:"
echo "  - Azure OpenAI: $OPENAI_ENDPOINT"
echo "  - Model: $OPENAI_MODEL_NAME"
echo "  - Search: $SEARCH_ENDPOINT"
echo ""
