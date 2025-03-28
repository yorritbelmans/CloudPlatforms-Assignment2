@description('Resource Group Location')
param location string = resourceGroup().location

@description('Virtual Network Name')
param vnetName string = 'CloudVnet'

@description('Subnet Name')
param subnetName string = 'CloudSubnet'

@description('Azure Container Registry Name')
param acrName string = 'CloudACR'

@description('Container Name')
param containerName string = 'CrudApp'

@description('Public IP Name')
param publicIpName string = 'CloudPublicIP'

@description('Network Security Group Name')
param nsgName string = 'CloudNSG'

@description('Container Instance Name')
param aciName string = 'CloudpACI'

@description('ACR SKU Type')
param acrSku string = 'Basic'

@description('Container Image Name')
param containerImage string = 'CloudACR.azurecr.io/cloudassignment2:v1'

@description('Container CPU Units')
param cpuCores int = 1

@description('Container Memory in GB')
param memoryInGb int = 1

@description('Port to expose on the container')
param containerPort int = 80

// ✅ Create Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

// ✅ Create Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// ✅ Create Network Security Group (NSG)
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: string(containerPort)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ✅ Create Azure Container Registry (ACR)
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

// ✅ Deploy Azure Container Instance (ACI)
resource aci 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: aciName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: containerImage
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          ports: [
            {
              protocol: 'TCP'
              port: containerPort
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: containerPort
        }
      ]
    }
    // networkProfile: {
    //   id: vnet.id
    // }
  }
}

// ✅ Output the Public IP Address
// output publicIPAddress string = publicIp.properties.ipAddress
