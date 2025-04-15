locals {
  connection_strings = [
    for connection_string in try(var.settings.connection_strings, []) : {
      name = connection_string.name
      type = connection_string.type
      value = (
        connection_string.type == "SQLAzure" ? "Server=${try(
          var.remote_objects.mssql_servers[connection_string.mssql_server_key].fully_qualified_domain_name,
          var.remote_objects.mssql_servers[var.client_config.landingzone_key][connection_string.mssql_server_key].fully_qualified_domain_name,
          connection_string.fully_qualified_domain_name,
          ""
          )},1433;Initial Catalog=${try(
          var.remote_objects.mssql_databases[connection_string.mssql_database_key].name,
          var.remote_objects.mssql_databases[var.client_config.landingzone_key][connection_string.mssql_database_key].name,
          connection_string.mssql_database_name,
          ""
        )};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=\"Active Directory Default\";" :
        connection_string.type == "SQLServer" ? "Server=${connection_string.server};Database=${connection_string.database};User Id=${connection_string.user};Password=${connection_string.password};" :
        connection_string.type == "PostgreSQL" ? "Host=${connection_string.host};Database=${connection_string.database};User Id=${connection_string.user};Password=${connection_string.password};" :
        connection_string.type == "MySQL" ? "Server=${connection_string.server};Database=${connection_string.database};User=${connection_string.user};Password=${connection_string.password};" :
        connection_string.type == "RedisCache" ? "${connection_string.host},password=${connection_string.password},ssl=True,abortConnect=False" :
        connection_string.type == "ServiceBus" ? "Endpoint=sb://${connection_string.namespace}.servicebus.windows.net/;SharedAccessKeyName=${connection_string.key_name};SharedAccessKey=${connection_string.key_value};" :
        connection_string.type == "EventHub" ? "Endpoint=sb://${connection_string.namespace}.servicebus.windows.net/;SharedAccessKeyName=${connection_string.key_name};SharedAccessKey=${connection_string.key_value};EntityPath=${connection_string.entity_path};" :
        connection_string.type == "NotificationHub" ? "Endpoint=sb://${connection_string.namespace}.servicebus.windows.net/;SharedAccessKeyName=${connection_string.key_name};SharedAccessKey=${connection_string.key_value};" :
        connection_string.type == "DocDb" ? "AccountEndpoint=${connection_string.endpoint};AccountKey=${connection_string.key};" :
        connection_string.type == "APIHub" ? "${connection_string.endpoint};ClientId=${connection_string.client_id};ClientSecret=${connection_string.client_secret};" :
        connection_string.type == "Custom" ? connection_string.value :
        connection_string.value
      )
    }
  ]
}
