resource "azurerm_network_manager_static_member" "static_member" {
  name = var.settings.name
  network_group_id = coalesce(
    try(var.settings.network_group_id, null),
    try(var.remote_objects.network_groups[var.settings.network_group.key].id, null),
    try(var.remote_objects.network_groups[try(var.settings.network_group.lz_key, var.client_config.landingzone_key)][var.settings.network_group.key].id, null)
  )
  target_virtual_network_id = coalesce(
    try(var.settings.target_virtual_network_id, null),
    try(var.remote_objects.vnets[try(var.settings.target_virtual_network.lz_key, var.client_config.landingzone_key)][var.settings.target_virtual_network.key].id, null)
  )

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) != null ? [var.settings.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
