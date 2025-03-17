locals {
  #arm_filename = "${path.module}/arm_site_config.json"

  app_settings = merge(
    try(var.settings.application_insight, null) == null ? {} : {
      "APPINSIGHTS_INSTRUMENTATIONKEY"             = try(
      var.remote_objects.application_insights[var.settings.application_insights.lz_key][var.settings.application_insights.key].instrumentation_key,
      var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insights.key].instrumentation_key,
      var.settings.application_insights.instrumentation_key,
    null),
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = try(
      var.remote_objects.application_insights[var.settings.application_insights.lz_key][var.settings.application_insights.key].connection_string,
      var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insights.key].connection_string,
      var.settings.application_insights.connection_string,
    null),
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
    },
    merge([
      #Managed identity "Server=tcp:<server-name>.database.windows.net;Authentication=Active Directory Default; Database=<database-name>;"
      for sql in try(var.settings.sqlconnections, []) : {
        "SQLAZURE_CONNECTION_STRING_${try(var.remote_objects.mssql_servers[sql.lz_key][sql.mssql_server_key].fully_qualified_domain_name,
        var.remote_objects.mssql_servers[var.client_config.landingzone_key][sql.mssql_server_key].fully_qualified_domain_name,
        sql.fully_qualified_domain_name,
        null)}" = "Server=tcp:${try(var.remote_objects.mssql_servers[sql.lz_key][sql.mssql_server_key].fully_qualified_domain_name,
        var.remote_objects.mssql_servers[var.client_config.landingzone_key][sql.mssql_server_key].fully_qualified_domain_name,
        sql.fully_qualified_domain_name,
        null)},1433;Authentication=Active Directory Default;Database=${try(var.remote_objects.mssql_databases[sql.lz_key][sql.mssql_database_key].name,
        var.remote_objects.mssql_databases[var.client_config.landingzone_key][sql.mssql_database_key].name,
        sql.mssql_database_name,
        null)};"
      }
    ]),

    try(var.settings.app_settings, {}),
    try(local.dynamic_settings_to_process, {})
  )
  backup_storage_account = can(var.settings.backup) ? var.remote_objects.storage_accounts[try(var.settings.backup.lz_key, var.client_config.landingzone_key)][var.settings.backup.storage_account_key] : null
  backup_sas_url         = can(var.settings.backup) ? "${local.backup_storage_account.primary_blob_endpoint}${local.backup_storage_account.containers[var.settings.backup.container_key].name}${data.azurerm_storage_account_blob_container_sas.backup[0].sas}" : null

  logs_storage_account = can(var.settings.logs) ? var.remote_objects.storage_accounts[try(var.settings.logs.lz_key, var.client_config.landingzone_key)][var.settings.logs.storage_account_key] : null
  logs_sas_url         = can(var.settings.logs) ? "${local.logs_storage_account.primary_blob_endpoint}${local.logs_storage_account.containers[var.settings.logs.container_key].name}${data.azurerm_storage_account_blob_container_sas.logs[0].sas}" : null

  http_logs_storage_account = can(var.settings.logs.http_logs) ? var.remote_objects.storage_accounts[try(var.settings.logs.http_logs.lz_key, var.client_config.landingzone_key)][var.settings.logs.http_logs.storage_account_key] : null
  http_logs_sas_url         = can(var.settings.logs.http_logs) ? "${local.http_logs_storage_account.primary_blob_endpoint}${local.http_logs_storage_account.containers[var.settings.logs.http_logs.container_key].name}${data.azurerm_storage_account_blob_container_sas.http_logs[0].sas}" : null
}
