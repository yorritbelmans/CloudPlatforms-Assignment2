resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'myfirsttest123'
  location: 'westeurope'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

