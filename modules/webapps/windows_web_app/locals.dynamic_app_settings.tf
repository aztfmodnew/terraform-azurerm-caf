locals {
  # Expected Variable: dynamic_app_settings = {
  #                      "KEYVAULT_URL" = {
  #                         keyvaults = {
  #                           my_common_vault = {
  #                             lz_key = "common_services_lz"
  #                             attribute_key = "vault_uri"
  #                           }
  #                         }
  #                      }
  #                     }
  dynamic_settings_to_process = {
    for setting in
    flatten(
      [
        for setting_name, resources in try(var.settings.dynamic_app_settings, {}) : [
          for resource_type_key, resource in resources : [
            for object_id_key, object_attributes in resource : {
              key   = setting_name
              value = try(var.remote_objects.combined_objects[resource_type_key][object_attributes.lz_key][object_id_key][object_attributes.attribute_key], var.remote_objects.combined_objects[resource_type_key][var.client_config.landingzone_key][object_id_key][object_attributes.attribute_key])
            }
          ]
        ]
      ]
    ) : setting.key => setting.value
  }

  /*
      {
      for sql_connection_key, sql_connection in try(var.settings.sql_connections.sql_connections_mi, {}) :
      "sql_connection_key" => {
        for sql_key, sql in sql_connection :
        "SQLAZURE_CONNECTION_STRING_${try(
          var.remote_objects.mssql_servers[sql.mssql_server_key].fully_qualified_domain_name,
          var.remote_objects.mssql_servers[var.client_config.landingzone_key][sql.mssql_server_key].fully_qualified_domain_name,
          sql.fully_qualified_domain_name,
          ""
        )}" => "Server=tcp:${try(
          var.remote_objects.mssql_servers[sql.mssql_server_key].fully_qualified_domain_name,
          var.remote_objects.mssql_servers[var.client_config.landingzone_key][sql.mssql_server_key].fully_qualified_domain_name,
          sql.fully_qualified_domain_name,
          ""
        )},1433;Authentication=Active Directory Default;Database=${try(
          var.remote_objects.mssql_databases[sql.mssql_database_key].name,
          var.remote_objects.mssql_databases[var.client_config.landingzone_key][sql.mssql_database_key].name,
          sql.mssql_database_name,
          ""
        )};"
      ...}
    }*/
}
