param appConfigStoreName string
param principalId string

resource appConfigStore 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
  name: appConfigStoreName
}

resource appConfigurationDataReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '516239f1-63e1-4d78-a4de-a74fb236a071'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appConfigStore.id, principalId, appConfigurationDataReaderRoleDefinition.id)
  scope: appConfigStore
  properties: {
    roleDefinitionId: appConfigurationDataReaderRoleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
