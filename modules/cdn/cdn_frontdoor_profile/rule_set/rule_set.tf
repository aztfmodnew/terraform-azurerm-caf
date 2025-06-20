# rule_set.tf
# Placeholder for azurerm_cdn_frontdoor_rule_set resource implementation

resource "azurerm_cdn_frontdoor_rule_set" "rule_set" {
  name                     = var.settings.name
  cdn_frontdoor_profile_id = var.settings.cdn_frontdoor_profile_id
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
