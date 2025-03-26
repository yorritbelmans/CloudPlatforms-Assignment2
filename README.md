# Cloud Platforms - Assignment2
## Azure Infrastucture-as-code
#### Thomas More Geel (2CCS02)

### Azure Cli & Bicep Setup

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


### Bicep Deployments
#### Create recource group
[resourcegroup.bicep](Bicep/tests/resourcegroup.bicep) file in repo

Run Deployment:
```
az deployment sub create --template-file resourcegroup.bicep --location eastus
```


#### Azure Container Registry
[containerRegistry.bicep](Bicep/tests/containerRegistry.bicep) file in repo

Run Deployment:
```
az deployment group create --resource-group Test --template-file containerRegistry.bicep --parameters acrName=assignment2
```