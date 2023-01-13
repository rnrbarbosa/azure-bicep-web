// Deploy Odoo on Azure

targetScope = 'subscription'

// Input Parameters
param azureRegion string = 'francecentral'
@minLength(3)
@maxLength(11)
@description('A prefix to be used on all resources')
param myPrefix string

@secure()
@description('Database Password to be used')
param dbPassword string

@description('Environment')
@allowed([
  'DEV'
  'TEST'
  'PROD'
])
param environment string
param project string
param solution string
var DbServerName  = 'db-${myPrefix}'



resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${myPrefix}-rg'
  location: azureRegion
  tags: {
    project: project
    solution: solution
    environment: environment
  }
}

module storage 'DATA/storage_001.bicep' = {
  name: 'stor-${myPrefix}'
  scope: rg
  params: {
    location: azureRegion
  }
}

module database 'SQL/db_001.bicep' = {
  name: 'db-${myPrefix}'
  scope: rg
  params: {
    administratorLoginPassword: dbPassword
    location: azureRegion
    serverName: DbServerName
  }
}

module monitoring 'MON/monitoring_001.bicep' = {
  name: 'mon-${myPrefix}'
  scope: rg
  params: {
    myPrefix: myPrefix
    location: azureRegion
  }
}

module capp 'ACA/aca_001.bicep' = {
  name: 'app-${myPrefix}'
  scope: rg
  params: {
    myPrefix: myPrefix
    location: azureRegion
    logCustomerId: monitoring.outputs.logCustId
    logSharedKey:  monitoring.outputs.logSharedKey
    StorageAccountName: storage.outputs.storageName
    StorageAccountKey: storage.outputs.storageKey
    DbHost: database.outputs.db_host
    DbUser: database.outputs.db_user
    DbPass: dbPassword
    DockerRegistryUrl: 'docker.io'
    DockerRegistryUsername: ''
    DockerRegistryPassword: ''
    DockerImageName: 'odoo'
    DockerImageTag: '15'
  }
}

