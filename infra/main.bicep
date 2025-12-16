@description('Location for all resources')
param location string = 'uksouth'

@description('Admin Object ID for SQL Server Entra ID authentication')
param adminObjectId string

@description('Admin login name (UPN) for SQL Server')
param adminLogin string

@description('Deploy GenAI resources')
param deployGenAI bool = false

// Generate base name for all resources
var baseName = toLower('expensemgmt-${uniqueString(resourceGroup().id)}')

// Deploy App Service and Managed Identity
module appService 'modules/app-service.bicep' = {
  name: 'app-service-deployment'
  params: {
    location: location
    baseName: baseName
  }
}

// Deploy Azure SQL
module azureSQL 'modules/azure-sql.bicep' = {
  name: 'azure-sql-deployment'
  params: {
    location: location
    baseName: baseName
    adminObjectId: adminObjectId
    adminLogin: adminLogin
    managedIdentityPrincipalId: appService.outputs.managedIdentityPrincipalId
  }
}

// Conditionally deploy GenAI resources
module genAI 'modules/genai.bicep' = if (deployGenAI) {
  name: 'genai-deployment'
  params: {
    baseName: baseName
    managedIdentityPrincipalId: appService.outputs.managedIdentityPrincipalId
  }
  dependsOn: [
    appService
  ]
}

// Outputs
output resourceGroupName string = resourceGroup().name
output appServiceName string = appService.outputs.appServiceName
output appServiceUrl string = appService.outputs.appServiceUrl
output managedIdentityClientId string = appService.outputs.managedIdentityClientId
output sqlServerName string = azureSQL.outputs.sqlServerName
output sqlServerFqdn string = azureSQL.outputs.sqlServerFqdn
output databaseName string = azureSQL.outputs.databaseName
output openAIEndpoint string = deployGenAI ? genAI.outputs.openAIEndpoint : ''
output openAIModelName string = deployGenAI ? genAI.outputs.openAIModelName : ''
output searchEndpoint string = deployGenAI ? genAI.outputs.searchEndpoint : ''
