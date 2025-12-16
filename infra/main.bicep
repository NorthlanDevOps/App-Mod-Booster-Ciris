targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = 'uksouth'

@description('Admin Object ID for SQL Server')
param adminObjectId string

@description('Admin Login for SQL Server')
param adminLogin string

@description('Whether to deploy GenAI resources')
param deployGenAI bool = false

var uniqueSuffix = uniqueString(resourceGroup().id)

// Deploy App Service with Managed Identity
module appService 'modules/app-service.bicep' = {
  name: 'app-service-deployment'
  params: {
    location: location
    uniqueSuffix: uniqueSuffix
  }
}

// Deploy Azure SQL Database
module azureSQL 'modules/azure-sql.bicep' = {
  name: 'azure-sql-deployment'
  params: {
    location: location
    uniqueSuffix: uniqueSuffix
    adminObjectId: adminObjectId
    adminLogin: adminLogin
    managedIdentityPrincipalId: appService.outputs.managedIdentityPrincipalId
  }
}

// Deploy GenAI resources (conditional)
module genAI 'modules/genai.bicep' = if (deployGenAI) {
  name: 'genai-deployment'
  params: {
    location: location
    uniqueSuffix: uniqueSuffix
    managedIdentityPrincipalId: appService.outputs.managedIdentityPrincipalId
  }
}

// Outputs
output appServiceName string = appService.outputs.appServiceName
output appServiceUrl string = appService.outputs.appServiceUrl
output managedIdentityName string = appService.outputs.managedIdentityName
output managedIdentityClientId string = appService.outputs.managedIdentityClientId
output sqlServerName string = azureSQL.outputs.sqlServerName
output sqlServerFqdn string = azureSQL.outputs.sqlServerFqdn
output databaseName string = azureSQL.outputs.databaseName
output openAIEndpoint string = deployGenAI ? genAI.outputs.openAIEndpoint : ''
output openAIModelName string = deployGenAI ? genAI.outputs.openAIModelName : ''
output searchEndpoint string = deployGenAI ? genAI.outputs.searchEndpoint : ''
output openAIName string = deployGenAI ? genAI.outputs.openAIName : ''
output searchServiceName string = deployGenAI ? genAI.outputs.searchServiceName : ''
