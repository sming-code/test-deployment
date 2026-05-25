param env_name string
param server_name string = '${env_name}-tag'
// param logical_area string
// param service_name string

resource database_server 'Microsoft.Sql/servers@2025-02-01-preview' = {
  name: server_name
  location: 'uksouth'
}

output sql_server_name string = database_server.id
