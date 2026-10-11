resource "azurecaf_name" "sqlpool" {
  name          = var.settings.name
  resource_type = "azurerm_synapse_spark_pool"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                      = azurecaf_name.sqlpool.result
  synapse_workspace_id      = var.synapse_workspace_id
  sku_name                  = var.settings.sku_name
  create_mode               = var.settings.create_mode
  storage_account_type      = var.settings.storage_account_type
  collation                 = try(var.settings.collation, null)
  data_encrypted            = try(var.settings.data_encrypted, null)
  recovery_database_id      = try(var.settings.recovery_database_id, null)
  geo_backup_policy_enabled = var.settings.geo_backup_policy_enabled
  tags                      = local.tags

  dynamic "restore" {
    for_each = try(var.settings.restore, null) == null ? [] : [var.settings.restore]

    content {
      point_in_time      = restore.value.point_in_time
      source_database_id = restore.value.source_database_id
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
