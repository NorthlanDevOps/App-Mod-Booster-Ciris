@description('Location for all resources')
param location string = resourceGroup().location

@description('Base name for resources')
param baseName string

@description('Admin Object ID for Entra ID authentication')
param adminObjectId string

@description('Admin login name (UPN)')
param adminLogin string

@description('Managed Identity Principal ID for database access')
param managedIdentityPrincipalId string

// Create SQL Server with Entra ID-only authentication
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'sql-${baseName}'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: guid(subscription().id, resourceGroup().id, baseName)
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Configure Entra ID administrator
resource sqlAdministrator 'Microsoft.Sql/servers/administrators@2021-11-01' = {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: adminLogin
    sid: adminObjectId
    tenantId: subscription().tenantId
    azureADOnlyAuthentication: true
  }
}

// Create firewall rule to allow Azure services
resource firewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Create Northwind database
resource database 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: 'Northwind'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}

output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = database.name
