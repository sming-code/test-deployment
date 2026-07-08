param keyvaultName string
param principalId string
param tenantId string

resource keyvault 'Microsoft.KeyVault/vaults@2026-02-01' existing = {
  name: keyvaultName
}

resource keyvaultPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2026-02-01' = {
  properties: {
    accessPolicies:  [
       {
        objectId: principalId
        permissions: {
           secrets: [
             'get'
             'list'
           ]
        }
        tenantId: tenantId
       }
    ]
  }
  parent: keyvault
  name: 'add'
}
