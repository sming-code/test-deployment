param database_name string
param server_name string
param environment_resource_group_name string

@secure()
param container_app_principal_id string

resource database_server 'Microsoft.Sql/servers@2025-02-01-preview' = {
  name: server_name
  location: 'uksouth'
}

resource sql_database 'Microsoft.Sql/servers/databases@2025-02-01-preview' = {
  parent: database_server
  name: database_name
  location: 'uksouth'
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    requestedBackupStorageRedundancy: 'Local'
    minCapacity: json('0.5')
    maintenanceConfigurationId: '/subscriptions/b435bfd7-28d3-4016-955b-baf44b31c6b5/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
    availabilityZone: 'NoPreference'
  }
}

resource threat_protection 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2025-02-01-preview' = {
  parent: sql_database
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource auditing_policies 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: sql_database
  name: 'Default'
  properties: {
    auditingState: 'Disabled'
  }
}

resource auditing_settings 'Microsoft.Sql/servers/databases/auditingSettings@2025-02-01-preview' = {
  parent: sql_database
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource short_term_retention_policies 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2025-02-01-preview' = {
  parent: sql_database
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
}

resource geo_backup_policies 'Microsoft.Sql/servers/databases/geoBackupPolicies@2025-02-01-preview' = {
  parent: sql_database
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

module sqlServerContributorPolicyAssignment 'sql-db-contributor-role-assignment.bicep' = {
  params: {
    serverName: server_name
    principalId: container_app_principal_id
  }
  scope: resourceGroup(environment_resource_group_name)
}

output sql_server_name string = database_server.name
output sql_database_name string = sql_database.name
