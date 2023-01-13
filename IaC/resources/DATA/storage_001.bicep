@description('Azure region where resources should be deployed')


param location string = resourceGroup().location
var storageAccountName = 'sto${uniqueString(resourceGroup().id)}'

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource fileService 'fileServices' = {
    name: 'default'
    properties: {
      enabledProtocols: 'SMB'
      shareQuota: 10
    }

    resource data 'shares' = {
      name: 'data'
    }
    resource addons 'shares' = {
      name: 'addons'
    }
  }
}

output storageName string = storage.name
output storageKey string = storage.listKeys().keys[0].value
