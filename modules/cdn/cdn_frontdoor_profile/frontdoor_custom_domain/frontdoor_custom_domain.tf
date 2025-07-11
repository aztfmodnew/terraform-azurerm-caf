resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  name = azurecaf_name.custom_domain.result
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )
  host_name   = var.settings.host_name
  dns_zone_id = try(var.settings.dns_zone_id, null)

  # Pre-validated custom domain (for Azure services like Static Web App)
  # pre_validated_cdn_frontdoor_custom_domain_id = try(var.settings.pre_validated_cdn_frontdoor_custom_domain_id, null)

  tls {
    certificate_type = try(var.settings.tls.certificate_type, "ManagedCertificate")
    cdn_frontdoor_secret_id = coalesce(
      try(var.settings.tls.cdn_frontdoor_secret_id, null),
      try(var.remote_objects.cdn_frontdoor_secrets[try(var.settings.tls.cdn_frontdoor_secret.lz_key, var.client_config.landingzone_key)][var.settings.tls.cdn_frontdoor_secret.key].id, null),
      try(var.remote_objects.cdn_frontdoor_secrets[var.settings.tls.secret_key].id, null)
    )
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
