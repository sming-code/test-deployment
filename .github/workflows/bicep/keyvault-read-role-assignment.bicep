param keyvaultName string
param principalId string

resource keyVault 'Microsoft.KeyVault/vaults@2026-02-01' existing = {
  name: keyvaultName
}

resource keyVaultReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '21090545-7ca7-4776-b22c-e363652d74d2'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: 'just a name'
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultReaderRoleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
