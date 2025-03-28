@description('Public IP Name')
param publicIpName string = 'CloudPublicIP'

@description('Resource Group Location')
param location string = resourceGroup().location

@description('Virtual Network Name')
param vnetName string = 'CloudVnet'

@description('Subnet Name')
param subnetName string = 'CloudSubnet'

@description('Network Security Group Name')
param nsgName string = 'CloudNSG'

@description('Port to expose on the container')
param containerPort int = 80

@description('Name for the loadbalancer')
param loadBalancerName string = 'CloudLoadBalancer'

@description('Name for the backendpoolname')
param backendPoolName string = 'CloudBackEndPool'


// Create Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIpName
  location: location
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
        name: subnetName
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
