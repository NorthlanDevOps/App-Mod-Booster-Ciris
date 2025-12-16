#!/bin/bash
set -e

echo "=========================================="
echo "App Modernization Deployment Script"
echo "=========================================="

# Configuration
RESOURCE_GROUP="rg-appmod-demo"
LOCATION="uksouth"
DEPLOYMENT_NAME="appmod-deployment-$(date +%s)"

# Get current user info for SQL admin
ADMIN_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
ADMIN_LOGIN=$(az ad signed-in-user show --query userPrincipalName -o tsv)

echo "Admin Object ID: $ADMIN_OBJECT_ID"
echo "Admin Login: $ADMIN_LOGIN"

# Create resource group if it doesn't exist
echo "Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output none

echo "Deploying infrastructure..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --name $DEPLOYMENT_NAME \
    --template-file infra/main.bicep \
    --parameters location=$LOCATION \
    --parameters adminObjectId=$ADMIN_OBJECT_ID \
    --parameters adminLogin=$ADMIN_LOGIN \
    --parameters deployGenAI=false \
    --output json)

# Extract outputs
APP_SERVICE_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.appServiceName.value')
MANAGED_IDENTITY_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.managedIdentityName.value')
MANAGED_IDENTITY_CLIENT_ID=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.managedIdentityClientId.value')
SQL_SERVER_FQDN=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.sqlServerFqdn.value')
SQL_SERVER_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.sqlServerName.value')
DATABASE_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.databaseName.value')
APP_SERVICE_URL=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.appServiceUrl.value')

echo ""
echo "Deployment completed successfully!"
echo "App Service Name: $APP_SERVICE_NAME"
echo "Managed Identity: $MANAGED_IDENTITY_NAME"
echo "SQL Server: $SQL_SERVER_NAME"
echo "Database: $DATABASE_NAME"
echo ""

# Configure App Service Settings
echo "Configuring App Service settings..."
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_SERVICE_NAME \
    --settings \
        "ConnectionStrings__DefaultConnection=Server=tcp:${SQL_SERVER_FQDN};Database=${DATABASE_NAME};Authentication=Active Directory Managed Identity;User Id=${MANAGED_IDENTITY_CLIENT_ID};" \
        "AZURE_CLIENT_ID=${MANAGED_IDENTITY_CLIENT_ID}" \
        "ManagedIdentityClientId=${MANAGED_IDENTITY_CLIENT_ID}" \
    --output none

echo "Waiting 30 seconds for SQL Server to be fully ready..."
sleep 30

# Add current IP to SQL firewall
echo "Adding current IP to SQL firewall..."
MY_IP=$(curl -s https://api.ipify.org)

# Allow Azure services access
echo "Allowing Azure services access to SQL Server..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name "AllowAllAzureIPs" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --output none 2>/dev/null || echo "Azure services firewall rule already exists"

# Add deployment IP
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name "AllowDeploymentIP" \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP \
    --output none 2>/dev/null || echo "Deployment IP firewall rule already exists"

echo "Waiting additional 15 seconds for firewall rules to propagate..."
sleep 15

# Install required Python packages if not already installed
echo "Installing Python dependencies..."
pip3 install --quiet pyodbc azure-identity

# Update Python script with actual values
echo "Updating database connection settings..."
sed -i.bak "s/SERVER = \"example.database.windows.net\"/SERVER = \"${SQL_SERVER_FQDN}\"/" run-sql.py && rm -f run-sql.py.bak
sed -i.bak "s/DATABASE = \"database_name\"/DATABASE = \"${DATABASE_NAME}\"/" run-sql.py && rm -f run-sql.py.bak
sed -i.bak "s/SQL_SCRIPT_FILE = \"Database-Schema\/database_schema.sql\"/SQL_SCRIPT_FILE = \"Database-Schema\/database_schema.sql\"/" run-sql.py && rm -f run-sql.py.bak

# Import database schema
echo "Importing database schema..."
python3 run-sql.py

# Update script.sql with managed identity name
echo "Updating database role script..."
sed -i.bak "s/MANAGED-IDENTITY-NAME/${MANAGED_IDENTITY_NAME}/g" script.sql && rm -f script.sql.bak

# Update run-sql-dbrole.py with actual values
sed -i.bak "s/SERVER = \"example.database.windows.net\"/SERVER = \"${SQL_SERVER_FQDN}\"/" run-sql-dbrole.py && rm -f run-sql-dbrole.py.bak
sed -i.bak "s/DATABASE = \"database_name\"/DATABASE = \"${DATABASE_NAME}\"/" run-sql-dbrole.py && rm -f run-sql-dbrole.py.bak

# Configure database roles for managed identity
echo "Configuring database roles..."
python3 run-sql-dbrole.py

# Update run-sql-stored-procs.py with actual values
sed -i.bak "s/SERVER = \"example.database.windows.net\"/SERVER = \"${SQL_SERVER_FQDN}\"/" run-sql-stored-procs.py && rm -f run-sql-stored-procs.py.bak
sed -i.bak "s/DATABASE = \"database_name\"/DATABASE = \"${DATABASE_NAME}\"/" run-sql-stored-procs.py && rm -f run-sql-stored-procs.py.bak
sed -i.bak "s/SQL_SCRIPT_FILE = \"script.sql\"/SQL_SCRIPT_FILE = \"stored-procedures.sql\"/" run-sql-stored-procs.py && rm -f run-sql-stored-procs.py.bak

# Deploy stored procedures
echo "Deploying stored procedures..."
python3 run-sql-stored-procs.py

# Deploy application code
echo "Deploying application code..."
if [ -f "app/app.zip" ]; then
    az webapp deploy \
        --resource-group $RESOURCE_GROUP \
        --name $APP_SERVICE_NAME \
        --src-path app/app.zip \
        --type zip
    echo "Application deployed successfully!"
else
    echo "Warning: app/app.zip not found. Please build the application first."
fi

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "App Service URL: ${APP_SERVICE_URL}/Index"
echo "Note: Navigate to /Index to view the app"
echo ""
echo "To run the app locally:"
echo "1. Update appsettings.json connection string to use 'Authentication=Active Directory Default'"
echo "2. Run 'az login' to authenticate"
echo "3. Run 'dotnet run' from the app directory"
echo ""
