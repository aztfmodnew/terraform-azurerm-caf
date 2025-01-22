resource "azurerm_network_manager_deployment" "manager_deployment" {
  network_manager_id = coalesce(
    try(var.settings.network_manager_id, null),
    try(var.remote_objects.network_manager_id, null),
    try(var.remote_objects.network_managers[try(var.settings.network_manager.lz_key, var.client_config.landingzone_key)][var.settings.network_manager.key].id, null)
  )
  location     = var.settings.location
  scope_access = var.settings.scope_access
  configuration_ids = concat(
    try(var.settings.configuration_ids, []),
    [
      for security_admin_configuration in try(var.settings.security_admin_configurations, []) : coalesce(
        try(var.remote_objects.security_admin_configurations[try(security_admin_configuration.key)].id, null),
        try(var.remote_objects.security_admin_configurations[try(security_admin_configuration.lz_key, var.client_config.landingzone_key)][security_admin_configuration.key].id, null)

      )
    ],
    [
      for connectivity_configuration in try(var.settings.connectivity_configurations, []) : coalesce(
        try(var.remote_objects.connectivity_configurations[try(connectivity_configuration.key)].id, null),
        try(var.remote_objects.connectivity_configurations[try(connectivity_configuration.lz_key, var.client_config.landingzone_key)][connectivity_configuration.key].id, null)
      )
    ]
  )
  triggers = try(var.settings.triggers, null)

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
