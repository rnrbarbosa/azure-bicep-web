// Global Parameters
@minLength(3)
@maxLength(11)
param myPrefix string
param location string = resourceGroup().location

//------------------------------------------
//--- DEPLOY Workpace Monitoring
//---------------------- --------------------
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${myPrefix}-capp-mon'
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
  }
}

output logCustId string = logAnalytics.properties.customerId
output logSharedKey string = logAnalytics.listKeys().primarySharedKey
