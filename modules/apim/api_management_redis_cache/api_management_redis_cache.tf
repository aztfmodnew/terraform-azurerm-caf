resource "azurerm_api_management_redis_cache" "resource" {
  name              = azurecaf_name.resource.result
  api_management_id = local.api_management_id
  connection_string = sensitive(local.connection_string)
  cache_location    = try(var.settings.cache_location, "default")
  description       = try(var.settings.description, null)
  redis_cache_id    = local.redis_cache_id

  dynamic "timeouts" {
    for_each = var.settings.timeouts == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
