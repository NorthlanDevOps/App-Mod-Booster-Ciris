@description('Location for all resources')
param location string

@description('Unique suffix for resource naming')
param uniqueSuffix string

@description('Managed Identity Principal ID')
param managedIdentityPrincipalId string

var openAIName = 'oai-appmod-${toLower(uniqueSuffix)}'
var searchServiceName = 'srch-appmod-${toLower(uniqueSuffix)}'
var openAILocation = 'swedencentral'
var modelName = 'gpt-4o'
var deploymentName = 'gpt-4o'

// Cognitive Services OpenAI User role
var cognitiveServicesOpenAIUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
// Search Index Data Contributor role
var searchIndexDataContributorRoleId = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'

// Create Azure OpenAI Account
resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAIName
  location: openAILocation
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAIName
    publicNetworkAccess: 'Enabled'
  }
}

// Deploy GPT-4o Model
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: deploymentName
  sku: {
    name: 'Standard'
    capacity: 8
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: '2024-08-06'
    }
  }
}

// Grant Managed Identity access to Azure OpenAI
resource openAIRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAI.id, managedIdentityPrincipalId, cognitiveServicesOpenAIUserRoleId)
  scope: openAI
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAIUserRoleId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Create Azure Cognitive Search
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchServiceName
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
  }
}

// Grant Managed Identity access to Search Service
resource searchRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, managedIdentityPrincipalId, searchIndexDataContributorRoleId)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRoleId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output openAIEndpoint string = openAI.properties.endpoint
output openAIModelName string = deploymentName
output openAIName string = openAI.name
output searchEndpoint string = 'https://${searchService.name}.search.windows.net'
output searchServiceName string = searchService.name
