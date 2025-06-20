# secret.tf
# Placeholder for azurerm_cdn_frontdoor_secret resource implementation

resource "azurerm_cdn_frontdoor_secret" "secret" {
  name                     = var.settings.name
  cdn_frontdoor_profile_id = var.settings.cdn_frontdoor_profile_id
  secret {
    customer_certificate {
      key_vault_certificate_id = var.settings.secret.customer_certificate.key_vault_certificate_id
    }
  }
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
