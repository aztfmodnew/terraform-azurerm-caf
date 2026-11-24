resource "azurerm_monitor_private_link_scope" "scope" {
  name                  = azurecaf_name.scope.result
  resource_group_name   = local.resource_group_name
  ingestion_access_mode = try(var.settings.ingestion_access_mode, "Open")
  query_access_mode     = try(var.settings.query_access_mode, "Open")
  tags                  = local.tags

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

resource "azurerm_monitor_private_link_scoped_service" "scoped_service" {
  for_each = try(var.settings.scoped_services, {})

  name                = azurecaf_name.scoped_service[each.key].result
  resource_group_name = local.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.scope.name
  linked_resource_id = coalesce(
    try(each.value.linked_resource_id, null),
    try(var.remote_objects.log_analytics[try(each.value.log_analytics.lz_key, var.client_config.landingzone_key)][each.value.log_analytics.key].id, null),
    try(var.remote_objects.application_insights[try(each.value.application_insights.lz_key, var.client_config.landingzone_key)][each.value.application_insights.key].id, null)
  )

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
