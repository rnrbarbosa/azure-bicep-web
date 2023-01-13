//------ DATABASE ------------
@minLength(3)
@maxLength(11)
//----
param administratorLogin string = 'db_admin'
@secure()
param administratorLoginPassword string
param serverName string 
param serverEdition string = 'Burstable'
param skuSizeGB int = 32
param dbInstanceType string = 'Standard_B1ms'
// param haMode string = 'Disabled'
param availabilityZone string = '3'
param version string = '11'
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''

param location string = resourceGroup().location

//------------------------------------------
// ---- DEPLOY DATABASE
//------------------------------------------
resource database 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: serverName
  location: location
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    network: {
      delegatedSubnetResourceId: (empty(virtualNetworkExternalId) ? json('null') : json('${virtualNetworkExternalId}/subnets/${subnetName}'))
      privateDnsZoneArmResourceId: (empty(virtualNetworkExternalId) ? json('null') : privateDnsZoneArmResourceId)
    }
    highAvailability: {
      mode: 'Disabled'
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: availabilityZone
  }
}

resource allowAllPostgresDatabaseWindowsAzureIps 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-03-08-preview' = {
  name: 'AllowAllWindowsAzureIps' // don't change the name
  parent: database
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output db_user string =  database.properties.administratorLogin
output db_host string = database.properties.fullyQualifiedDomainName
