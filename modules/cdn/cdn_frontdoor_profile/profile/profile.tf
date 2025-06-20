# profile.tf
# Placeholder for azurerm_cdn_frontdoor_profile resource implementation

resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                = var.settings.name
  resource_group_name = local.resource_group_name
  sku_name            = var.settings.sku_name

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
    content {
      type         = var.settings.identity.type
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
    }
  }

  response_timeout_seconds = try(var.settings.response_timeout_seconds, null)

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
