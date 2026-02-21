# Naming for the notification hub namespace
resource "azurecaf_name" "notification_hub_namespace" {
  name          = var.settings.name
  resource_type = "azurerm_notification_hub_namespace"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  use_slug      = try(var.global_settings.use_slug, true)
  clean_input   = true
  separator     = try(var.global_settings.separator, "-")
}

# Naming for each notification hub
resource "azurecaf_name" "notification_hub" {
  for_each = try(var.settings.hubs, {})

  name          = each.value.name
  resource_type = "azurerm_notification_hub"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  use_slug      = try(var.global_settings.use_slug, true)
  clean_input   = true
  separator     = try(var.global_settings.separator, "-")
}

# Naming for each notification hub authorization rule
resource "azurecaf_name" "notification_hub_authorization_rule" {
  for_each = {
    for composite_key, value in flatten([
      for hub_key, hub in try(var.settings.hubs, {}) : [
        for rule_key, rule in try(hub.authorization_rules, {}) : {
          key  = "${hub_key}_${rule_key}"
          name = rule.name
        }
      ]
    ]) : value.key => value
  }

  name          = each.value.name
  resource_type = "azurerm_notification_hub_authorization_rule"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  use_slug      = try(var.global_settings.use_slug, true)
  clean_input   = true
  separator     = try(var.global_settings.separator, "-")
}
