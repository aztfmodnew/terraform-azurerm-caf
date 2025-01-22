resource "azurerm_network_manager_connectivity_configuration" "connectivity_configuration" {
  name = var.settings.name
  network_manager_id = coalesce(
    try(var.settings.network_manager_id, null),
    try(var.remote_objects.network_manager_id, null),
    try(var.remote_objects.network_managers[try(var.settings.network_manager.lz_key, var.client_config.landingzone_key)][var.settings.network_manager.key].id, null)
  )
  dynamic "applies_to_group" {
    for_each = var.settings.applies_to_groups
    content {
      group_connectivity = applies_to_group.value.group_connectivity
      network_group_id = coalesce(
        try(applies_to_group.value.network_group_id, null),
        try(var.remote_objects.network_groups[applies_to_group.value.network_group.key].id, null),
        try(var.remote_objects.network_groups[try(applies_to_group.value.network_group.lz_key, var.client_config.landingzone_key)][applies_to_group.value.network_group.key].id, null)
      )
      global_mesh_enabled = try(applies_to_group.value.global_mesh_enabled, null)
      use_hub_gateway     = try(applies_to_group.value.use_hub_gateway, null)
    }
  }
  connectivity_topology           = var.settings.connectivity_topology
  delete_existing_peering_enabled = try(var.settings.delete_existing_peering_enabled, null)
  description                     = try(var.settings.description, null)
  global_mesh_enabled             = try(var.settings.global_mesh_enabled, null)

  hub {
    resource_id = coalesce(
      try(var.settings.hub.resource_id, null),
      try(var.remote_objects.vnets[try(var.settings.hub.vnet.lz_key, var.client_config.landingzone_key)][var.settings.hub.vnet.key].id, null)
    )
    resource_type = try(var.settings.hub.resource_type, null)
  }


  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) != null ? [var.settings.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
