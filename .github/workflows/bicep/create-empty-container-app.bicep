param container_app_name string
param environment_name string
param container_image string

@secure()
param ghcr_user_name string
@secure()
param ghcr_password string


resource container_app_environment 'Microsoft.App/managedEnvironments@2026-01-01' existing = {
  name: 'caenv_${environment_name}_tag_private_name'
}

resource containerapps_ca_traveller_svc_dev_prd_334_name_resource 'Microsoft.App/containerapps@2026-01-01' = {
  name: container_app_name
  location: 'UK South'
  kind: 'containerapps'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: container_app_environment.id
    environmentId: container_app_environment.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: 'ghcr.io'
          username: ghcr_user_name
          passwordSecretRef: ghcr_password
        }
      ]
      maxInactiveRevisions: 100
      identitySettings: []
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/sming-code/${container_image}'
          name: container_app_name
          command: []
          args: []
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
        cooldownPeriod: 300
        pollingInterval: 30
      }
    }
  }
}
