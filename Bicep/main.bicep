@description('Public IP Name')
param publicIpName string = 'CloudPublicIP'

@description('Resource Group Location')
param location string = resourceGroup().location

@description('Virtual Network Name')
param vnetName string = 'CloudVnet'

@description('Subnet Name for aci')
param ACIsubnetName string = 'CloudSubnet-ACI'

@description('Subnet Name for app gateway')
param APGsubnetName string = 'CloudSubnet-APG'

@description('Network Security Group Name')
param nsgName string = 'CloudNSG'

@description('Port to expose on the container')
param containerPort int = 80




@description('Name for the container group')
param name string = 'cloud-assignment1-app'

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'assignment2.azurecr.io/crud-app:v1'

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



@description('Name of the Log Analytics Workspace')
param logAnalyticsWorkspaceName string = 'CloudLogWorkspace'



param appGwName string = 'CloudAppGateway'
param aciPort int = 80





// Create Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

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
        name: ACIsubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'aciDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
          networkSecurityGroup: {
            id: nsg.id // Associate NSG
          }
        }
      }
      {
        name: APGsubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}


// Create Network Security Group (NSG)
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

// Create Analytics logs for aci container logs
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {}
}


// ACI container creation
resource container 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: name
  location: location
  dependsOn: [
    // vnet
  ]
  identity: {
    type: 'SystemAssigned'
  }
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
    diagnostics: {
      logAnalytics: {
        workspaceId: logAnalytics.properties.customerId
        workspaceKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    ipAddress: {
      type: 'Private'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
    subnetIds: [
      {
        id: vnet.properties.subnets[0].id
      }
    ]
    imageRegistryCredentials: [
      {
        server: 'assignment2.azurecr.io'
        username: 'cloudtoken'
        password: 'wXOB5J3OHe4Q1eS93PQNaJgjrYrid6iBWN8nx47MFg+ACRCYgiRy'
      }
    ]
  }
}



// Create Application Gateway
resource appGateway 'Microsoft.Network/applicationGateways@2021-08-01' = {
  name: appGwName
  location: location
  dependsOn: [
    // vnet
    // publicIp
    // container
  ]
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1 
    }
    gatewayIPConfigurations: [
      {
        name: 'gatewayConfig'
        properties: {
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendConfig'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: container.properties.ipAddress.ip
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: aciPort
          protocol: 'Http'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'frontendConfig')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'frontendPort')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'httpSettings')
          }
        }
      }
    ]
  }
}
