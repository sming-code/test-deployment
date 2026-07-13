param log_analytics_workspace_name string
param log_analytics_resource_group_name string
param app_insights_name string

resource log_analytics_workspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
  name: log_analytics_workspace_name
  scope: resourceGroup(log_analytics_resource_group_name)
}

resource app_insights 'Microsoft.Insights/components@2020-02-02' = {
  name: app_insights_name
  location: 'uksouth'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    RetentionInDays: 90
    WorkspaceResourceId: log_analytics_workspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}
