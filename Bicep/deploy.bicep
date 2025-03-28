@description('Resource Group Location')
param location string = resourceGroup().location

@description('Virtual Network Name')
param vnetName string = 'CloudVnet'

@description('Subnet Name')
param subnetName string = 'CloudSubnet'




@description('Name for the container group')
param name string = 'cloud-Assignment1_APP'

@description('Container Image Name')
param image string = 'CloudACR.azurecr.io/cloudassignment2:v1'

@description('Port to open on the container and the public IP address.')
param port int = 80

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 1

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'





// Create Virtual Network
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

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Private'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
    // networkProfile: {
    //   id: resourceId('Microsoft.Network/networkProfiles', 'myNetworkProfile')
    // }
    subnetIds: [
      {
        id: vnet.properties.subnets[0].id
      }
    ]
  }
}
