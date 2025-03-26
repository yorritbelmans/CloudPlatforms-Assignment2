# Cloud Platforms - Assignment2
## Azure Infrastucture-as-code
#### Thomas More Geel (2CCS02)

## Azure Cli & Bicep Setup

- Ubuntu Azure CLI intall:
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

- Login to Azure CLI

```
az login
```

- Install Bicep
```
az bicep install && az bicep upgrade
```


## Bicep Deployments
### recource group setup
[resourcegroup.bicep](Bicep/tests/resourcegroup.bicep) file in repo

#### Run Deployment:
```
az deployment sub create --template-file resourcegroup.bicep --location eastus
```


### Azure Container Registry setup
[containerRegistry.bicep](Bicep/tests/containerRegistry.bicep) file in repo

#### Run Deployment:
```
az deployment group create --resource-group Test --template-file containerRegistry.bicep --parameters acrName=assignment2
```

#### Push image to registry (Azure CLI)
1. Login to registry
```
az acr login --name [ACR NAME]
```
2. Build docker file and tag
```
docker tag [DOCKER IMAGE NAME] [FULL LOGIN SERVER NAME]/crud-app:v1
```
3. Push image to registry
```
docker push [IMAGE WITH NEW TAG]
```
