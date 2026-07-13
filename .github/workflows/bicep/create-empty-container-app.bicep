param app_config_name string
param app_insights_name string
param container_app_name string
param environment string
param environment_resource_group_name string

var environmentKeyVaultName string = 'kv-${environment}-tag'
var environmentAppConfigurationName string = 'app-config-${environment}-tag'

@secure()
param container_app_environment_id string
@secure()
param ghcr_username string
@secure()
param ghcr_token string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: app_insights_name
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
  name: app_config_name
  scope: resourceGroup(environment_resource_group_name)
}

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
        {
          name: 'app-insights-endpoint'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'app-config-endpoint'
          value: appConfig.properties.endpoint
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        clientCertificateMode: 'Ignore'
        stickySessions: {
          affinity: 'none'
        }
      }
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

module appConfigurationPolicyAssignment 'app-configuration-user-role-assignment.bicep' = {
  params: {
    appConfigStoreName: environmentAppConfigurationName
    principalId: container_app.identity.principalId
  }
  scope: resourceGroup(environment_resource_group_name)
}
