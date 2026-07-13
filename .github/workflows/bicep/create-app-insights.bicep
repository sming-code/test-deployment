param logAnalyticsWorkspaceName string
param logAnalyticsResourceGroupName string
param appInsightsName string

resource log_analytics_workspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsResourceGroupName)
}

resource app_insights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
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
