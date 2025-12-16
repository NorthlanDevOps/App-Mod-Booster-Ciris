@description('Base name for resources')
param baseName string

@description('Managed Identity Principal ID for role assignments')
param managedIdentityPrincipalId string

// Azure OpenAI in swedencentral (lowercase name required)
resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: toLower('aoai-${baseName}')
  location: 'swedencentral'
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: toLower('aoai-${baseName}')
    publicNetworkAccess: 'Enabled'
  }
}

// Deploy GPT-4o model
resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 8
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-05-13'
    }
  }
}

// Cognitive Search for RAG (lowercase name required)
resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: toLower('search-${baseName}')
  location: resourceGroup().location
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
  }
}

// Role assignment: Cognitive Services OpenAI User for managed identity
resource openAIRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAI.id, managedIdentityPrincipalId, 'CognitiveServicesOpenAIUser')
  scope: openAI
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd') // Cognitive Services OpenAI User
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment: Search Index Data Contributor for managed identity
resource searchRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(search.id, managedIdentityPrincipalId, 'SearchIndexDataContributor')
  scope: search
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8ebe5a00-799e-43f5-93ac-243d3dce84a7') // Search Index Data Contributor
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output openAIEndpoint string = openAI.properties.endpoint
output openAIModelName string = gpt4oDeployment.name
output openAIName string = openAI.name
output searchEndpoint string = 'https://${search.name}.search.windows.net'
output searchName string = search.name
