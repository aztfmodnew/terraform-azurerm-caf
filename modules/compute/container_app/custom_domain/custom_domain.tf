resource "azurerm_container_app_custom_domain" "custom_domain" {
  name = var.settings.name
  container_app_id = coalesce(
    try(var.settings.container_app_id, null),
    try(var.remote_objects.container_app.id, null),
    try(var.remote_objects.container_apps[try(var.settings.container_app.lz_key, var.client_config.landingzone_key)][var.settings.container_app.key].id, null)
  )

  container_app_environment_certificate_id = coalesce(
    try(var.settings.container_app_environment_certificate_id, null),
    try(var.remote_objects.container_app_environment_certificates[try(var.settings.certificate.lz_key, var.client_config.landingzone_key)][var.settings.certificate.key].id, null),
    try(var.remote_objects.container_app_environment_certificates[var.settings.certificate_key].id, null)
  )

  certificate_binding_type = try(var.settings.certificate_binding_type, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  # Note: For managed certificates, manually add ignore_changes in your configuration
  # lifecycle {
  #   ignore_changes = [certificate_binding_type, container_app_environment_certificate_id]
  # }
}
