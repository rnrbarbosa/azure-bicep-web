# Deploy of a Container App using BICEP

## Summary

This is a simple demo on how to deploy and expose Web App that uses:

- Docker Container as the Web App
- PostgreSQL Database
- Azure File Share Mounts

### Azure Services
The following Azure Services were used:
- Azure Storage Account
- Azure File Share
- Azure Log Analytics
- Azure Containers App
- Azure Postgresql Flexible Server

## Architecture (in Bicep)


![](./azure-aca-architecture.png)

## How to Use It

```sh
REGION='xxxxx'
az deployment sub create --location $REGION --template-file  ./Blueprints/main.bicep -c

az group list -o table
RG=""
az group delete --resource-group $RG --yes
```
Example:

```sh
$ az deployment sub create --location francecentral --template-file  ./Blueprints/001-WebApp.bicep -c

Please provide string value for 'myPrefix' (? for help): dev-001
Please provide securestring value for 'dbPassword' (? for help): 
Please provide string value for 'environment' (? for help): 
 [1] DEV
 [2] TEST
 [3] PROD
Please enter a choice [Default choice(1)]: 1
 | Running ..
```
## Todo

- Azure Container Registry
- Azure Key Vault
