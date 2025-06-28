resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  name = azurecaf_name.custom_domain.result
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )
  host_name   = var.settings.host_name
  dns_zone_id = try(var.settings.dns_zone_id, null)

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
