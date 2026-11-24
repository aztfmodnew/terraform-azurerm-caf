# naming convention
resource "azurecaf_name" "law" {
  name          = var.log_analytics.name
  resource_type = "azurerm_log_analytics_workspace"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
resource "azurerm_log_analytics_workspace" "law" {
  name                                    = azurecaf_name.law.result
  location                                = local.location
  resource_group_name                     = local.resource_group_name
  allow_resource_only_permissions         = try(var.log_analytics.allow_resource_only_permissions, true)
  cmk_for_query_forced                    = try(var.log_analytics.cmk_for_query_forced, null)
  daily_quota_gb                          = lookup(var.log_analytics, "daily_quota_gb", null)
  data_collection_rule_id                 = try(var.log_analytics.data_collection_rule_id, null)
  immediate_data_purge_on_30_days_enabled = try(var.log_analytics.immediate_data_purge_on_30_days_enabled, null)
  internet_ingestion_access_type          = try(coalesce(try(var.log_analytics.internet_ingestion_access_type, null), try(var.log_analytics.internet_ingestion_enabled ? "Enabled" : "Disabled", null)), null)
  internet_query_access_type              = try(coalesce(try(var.log_analytics.internet_query_access_type, null), try(var.log_analytics.internet_query_enabled ? "Enabled" : "Disabled", null)), null)
  local_authentication_enabled            = try(var.log_analytics.local_authentication_enabled, true)
  reservation_capacity_in_gb_per_day      = try(coalesce(try(var.log_analytics.reservation_capacity_in_gb_per_day, null), try(var.log_analytics.reservation_capcity_in_gb_per_day, null)), null)
  sku                                     = lookup(var.log_analytics, "sku", "PerGB2018")
  retention_in_days                       = lookup(var.log_analytics, "retention_in_days", 30)
  tags                                    = merge(local.tags, try(var.log_analytics.tags, null))

  dynamic "identity" {
    for_each = try(var.log_analytics.identity, null) == null ? [] : [var.log_analytics.identity]

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.log_analytics.timeouts, null) == null ? [] : [var.log_analytics.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}