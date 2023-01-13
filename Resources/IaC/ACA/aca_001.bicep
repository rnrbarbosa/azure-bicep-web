//------ Container Apps ------------
@minLength(3)
@maxLength(11)
param myPrefix string
param location string = resourceGroup().location

param cAppName string = '${myPrefix}-app'

@description('Docker Registry URL')
param DockerRegistryUrl string

@description('Docker Registry username')
param DockerRegistryUsername string

@secure()
@description('Docker Registry password')
param DockerRegistryPassword string

@description('Docker image name')
param DockerImageName string

@description('Docker image tag')
param DockerImageTag string

// From logAnalytics Workspace
param logCustomerId string
param logSharedKey string

// From Storage Account
param StorageAccountName string
param StorageAccountKey string

// From Database
param DbUser string
param DbPass string
param DbHost string
//------------------------------------------
//--- DEPLOY Container Apps
//---------------------- --------------------

resource aca_env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${myPrefix}-capp-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logCustomerId
        sharedKey: logSharedKey
      }
    }
  }
}

resource aca_data 'Microsoft.App/managedEnvironments/storages@2022-03-01' = {
  name: 'share-data'
  parent: aca_env
  properties: {
    azureFile: {
      accountKey: StorageAccountKey
      accountName: StorageAccountName
      shareName: 'data'
      accessMode: 'ReadWrite'
    }
  }
}

resource aca_addons 'Microsoft.App/managedEnvironments/storages@2022-03-01' = {
  name: 'share-addons'
  parent: aca_env
  properties: {
    azureFile: {
      accountName: StorageAccountName
      accountKey: StorageAccountKey
      shareName: 'addons'
      accessMode: 'ReadWrite'
    }
  }
}


//------------------------------------------
//--- DEPLOY ACA Container EMS
//---------------------- --------------------
resource aca_pod 'Microsoft.App/containerApps@2022-03-01' = {
  name: '${myPrefix}-capp-pod'
  location: location
  properties: {
    managedEnvironmentId: aca_env.id
    configuration: {
      secrets: [
        {
          name: 'registry-password'
          value: DockerRegistryPassword
        }
      ]
      registries: [
        {
          passwordSecretRef: 'registry-password'
          server: DockerRegistryUrl
          username: DockerRegistryUsername
        }
      ]
      ingress: {
          external: true
          targetPort:8069
          allowInsecure: false
        }
    }
    template: {
      containers: [
        {
          name: cAppName
          image: '${DockerImageName}:${DockerImageTag}'
          env: [
            {
              name: 'USER'
              value: DbUser
            }
            {
              name: 'HOST'
              value: DbHost
            }
            {
              name: 'PASSWORD'
              value: DbPass
            }
          ]

          volumeMounts: [
            {
              volumeName:'data-share'
              mountPath:'/var/lib/odoo'
            }
            {
              volumeName:'addons-share'
              mountPath:'/mnt/extra-addons'
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'data-share'
          storageName: aca_data.name
          storageType: 'AzureFile'
        }
        {
          name: 'addons-share'
          storageName: aca_addons.name
          storageType: 'AzureFile'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 2
      }
    }
  }
}


