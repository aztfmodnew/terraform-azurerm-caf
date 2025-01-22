resource "azurerm_network_manager_management_group_connection" "management_group_connection" {

  name = var.settings.name
  network_manager_id = coalesce(
    try(var.settings.network_manager_id, null),
    try(var.remote_objects.network_manager_id, null),
    try(var.remote_objects.network_managers[try(var.settings.network_manager.lz_key, var.client_config.landingzone_key)][var.settings.network_manager.key].id, null)
  )
  management_group_id = coalesce(
    try(var.settings.management_group_id, null) /*,
    try(var.remote_objects.management_groups[var.settings.management_group.key].id, null),
    try(var.remote_objects.management_groups[try(var.settings.management_group.lz_key, var.client_config.landingzone_key)][var.settings.management_group.key].id, null)*/
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
