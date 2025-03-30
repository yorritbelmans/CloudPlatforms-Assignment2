# Cloud Platforms - Assignment2
## Azure Infrastucture-as-code
#### Thomas More Geel (2CCS02)

This repository contains the code for my individual assignment as part of my studies at Thomas More Geel. The task was to deploy a simple CRUD (Create, Read, Update, Delete) app to Azure using Infrastructure-as-Code (IaC) with Bicep templates. 

The project includes the following steps:

 - Learning about IaC and using Bicep templates to automate resource deployment.
 - Building a container image for a Flask-based CRUD app.
 - Creating an Azure Container Registry (ACR) and pushing the container image.
 - Deploying the container to Azure Container Instances (ACI).
 - Implementing best practices such as network configuration, security, and monitoring.

A diagram of the architecture and detailed steps are included to explain how I set up the infrastructure. All resources were cleaned up after the project to save Azure credits.

## Azure Architecture Overview 
![Design Diagram](Assignment2-Design.png)

This design routes internet traffic to an **Azure Container Instance (ACI)** via an **Application Gateway** within a **Virtual Network**.  

### **Key Components:**  
- **Application Gateway**: Routes `PublicIP:80` to ACI.  
- **Azure Container Instance (ACI)**: Runs containerized apps, pulling images from **Azure Container Registry**.  
- **Network Security Group (NSG)**: Allows inbound traffic on port `80`.  
- **Azure Monitor & Log Analytics**: Enables monitoring and logging.  

A secure, scalable, and monitored container deployment on Azure.  

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
This creates a new recourcegroup for all our recource to be deployed in.

#### Run Deployment:
```
az deployment sub create --template-file resourcegroup.bicep --location westeurope
```

#### Set default recourcegroup
```
az configure --defaults group="[resource group name]"
```


### Azure Container Registry setup
[containerRegistry.bicep](Bicep/tests/containerRegistry.bicep) file in repo

#### Run Deployment:
```
az deployment group create --template-file containerRegistry.bicep
```

#### Azure repository token (for push and pull permissions)
```
az acr token create --name cloudToken --registry [REGISTRY NAME] --repository [REPO LINK] content/write content/read --output json
```

´´´
docker login assignment2.azurecr.io -u [TOKEN NAME] -p [TOKEN PASSWORD]
´´´

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


### Azure container, network, monitor,.. deployment
[main.bicep](Bicep/main.bicep) file in repo
run to create following recources
 - PublicIP
 - Virtual Network with 2 subnets
 - Network Security Group
 - Analytics Workspace
 - Azure Container Instance
 - Application Gateway

This bicep files creates all these recources.
I adds the ACI in the correct subnet, publicIP to the AppGateway with ACI as backend, sends container logs to Azure Monitor, and restrics only http trafic in the subnet.

#### Run Deployment:
```
az deployment group create --template-file main.bicep
```

