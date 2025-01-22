resource "azurerm_network_manager_subscription_connection" "subscription_connection" {

  name            = var.settings.name
  subscription_id = var.settings.subscription_id
  network_manager_id = coalesce(
    try(var.settings.network_manager_id, null),
    try(var.remote_objects.network_manager_id, null),
    try(var.remote_objects.network_managers[try(var.settings.network_manager.lz_key, var.client_config.landingzone_key)][var.settings.network_manager.key].id, null)
  )


  description = try(var.settings.description, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) != null ? [var.settings.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
      update = try(timeouts.value.update, null)
    }
  }
}
