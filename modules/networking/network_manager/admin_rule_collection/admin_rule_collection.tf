resource "azurerm_network_manager_admin_rule_collection" "admin_rule_collection" {
  name = var.settings.name
  security_admin_configuration_id = coalesce(
    try(var.settings.security_admin_configuration_id, null),
    try(var.remote_objects.security_admin_configurations[try(var.settings.security_admin_configuration.key)].id, null),
    try(var.remote_objects.security_admin_configurations[try(var.settings.security_admin_configuration.lz_key, var.client_config.landingzone_key)][var.settings.security_admin_configuration.key].id, null)
  )
  network_group_ids = concat(
    try(var.settings.network_group_ids, []),
    [
      for network_group in var.settings.network_groups : coalesce(
        try(var.remote_objects.network_groups[network_group.key].id, null),
        try(var.remote_objects.network_groups[try(network_group.lz_key, var.client_config.landingzone_key)][network_group.key].id, null)
      )
    ]
  )
  description = try(var.settings.description, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) != null ? [var.settings.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
