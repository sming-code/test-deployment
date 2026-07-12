param environment string
param container_app_name string
param environmentKeyVaultName string = 'kv-${environment}-tag'
param environment_resource_group_name string
param log_analytics_workspace_name string
param app_insights_name string
param app_insights_exists string

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
  scope: resourceGroup(environment_resource_group_name)
}

module app_insights 'create-app-insights.bicep' = if (app_insights_exists == '0') {
  params: {
    appInsightsName: app_insights_name
    logAnalyticsWorkspaceName: log_analytics_workspace_name
  }
}
