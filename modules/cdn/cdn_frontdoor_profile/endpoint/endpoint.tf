# endpoint.tf
# Placeholder for azurerm_cdn_frontdoor_endpoint resource implementation

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = var.settings.name
  cdn_frontdoor_profile_id = var.settings.cdn_frontdoor_profile_id
  enabled                  = try(var.settings.enabled, true)
  
  tags = merge(local.tags, try(var.settings.tags, null))
  
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
