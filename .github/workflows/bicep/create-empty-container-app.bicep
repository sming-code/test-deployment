param environment string
param container_app_name string
param environmentKeyVaultName string = 'kv-${environment}-tag'
param environmentResourceGroupName string = 'rg-${environment}-tag'

@secure()
param container_app_environment_id string
@secure()
param ghcr_username string
@secure()
param ghcr_token string

resource container_app 'Microsoft.App/containerapps@2026-01-01' = {
  name: container_app_name
  location: 'UK South'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: container_app_environment_id
    configuration: {
      secrets: [
        {
          name: 'ghcr-token'
          value: ghcr_token
        }
      ]
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: 'ghcr.io'
          username: ghcr_username
          passwordSecretRef: 'ghcr-token'
        }
      ]
      maxInactiveRevisions: 100
      identitySettings: []
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/sming-code/empty-service-worker:1.0.0'
          name: container_app_name
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      revisionSuffix: '0000'
      scale: {
        minReplicas: 1
        maxReplicas: 1
        cooldownPeriod: 300
        pollingInterval: 30
      }
    }
  }
}

module keyvaultAppPolicyAssignment 'keyvault-secrets-user-role-assignment.bicep' = {
  params: {
    keyvaultName: environmentKeyVaultName
    principalId: container_app.identity.principalId
  }
  scope: resourceGroup(environmentResourceGroupName)
}
