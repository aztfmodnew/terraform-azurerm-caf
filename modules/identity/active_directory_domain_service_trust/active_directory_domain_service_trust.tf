resource "azurerm_active_directory_domain_service_trust" "adds_trust" {

  domain_service_id = coalesce(
    try(var.settings.domain_service_id, null),
    try(var.remote_objects.active_directory_domain_service[var.settings.active_directory_domain_service.key].id, null),
    try(var.remote_objects.active_directory_domain_service[var.settings.active_directory_domain_service.domain_service_id].id, null),
    try(var.remote_objects.active_directory_domain_service[var.settings.active_directory_domain_service.id].id, null)
  )

  name                   = var.settings.name
  password               = var.settings.password
  trusted_domain_dns_ips = var.settings.trusted_domain_dns_ips
  trusted_domain_fqdn    = var.settings.trusted_domain_fqdn

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
