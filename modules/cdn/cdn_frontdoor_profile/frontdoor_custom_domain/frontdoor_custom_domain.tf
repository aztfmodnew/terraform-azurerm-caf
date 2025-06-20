resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  name                     = var.settings.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  host_name                = var.settings.host_name
  dns_zone_id              = try(var.settings.dns_zone_id, null)

  tls {
    certificate_type = try(var.settings.tls.certificate_type, null)
    # minimum_tls_version is deprecated and should not be used
  }

  # timeouts block (static, not dynamic)
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}
