param container_app_name string

@secure()
param container_app_environment_id string
@secure()
param ghcr_password string

resource containerapps_ca_traveller_svc_dev_prd_334_name_resource 'Microsoft.App/containerapps@2026-01-01' = {
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
          name: 'ghcr-password'
          value: ghcr_password
        }
      ]
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: 'ghcr.io'
          passwordSecretRef: 'ghcr-password'
        }
      ]
      maxInactiveRevisions: 100
      identitySettings: []
    }
    template: {
      containers: [
        {
          image: 'sming-code/empty-service-worker:1.0.0'
          name: container_app_name
          command: []
          args: []
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
