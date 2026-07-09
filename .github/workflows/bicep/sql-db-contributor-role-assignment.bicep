param serverName string
param principalId string

resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: serverName
}

resource sqlDbContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(sqlServer.id, principalId, sqlDbContributorRoleDefinition.id)
  scope: sqlServer
  properties: {
    roleDefinitionId: sqlDbContributorRoleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
