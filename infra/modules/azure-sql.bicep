@description('Location for all resources')
param location string

@description('Unique suffix for resource naming')
param uniqueSuffix string

@description('Admin Object ID for SQL Server')
param adminObjectId string

@description('Admin Login for SQL Server')
param adminLogin string

@description('Managed Identity Principal ID')
param managedIdentityPrincipalId string

var sqlServerName = 'sql-appmod-${uniqueSuffix}'
var databaseName = 'Northwind'

// Create SQL Server
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: uniqueString(resourceGroup().id, sqlServerName)
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Configure Azure AD Administrator
resource sqlServerAdministrator 'Microsoft.Sql/servers/administrators@2021-11-01' = {
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

// Create Database
resource database 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: databaseName
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

// Allow Azure Services Firewall Rule
resource firewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Outputs
output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = database.name
