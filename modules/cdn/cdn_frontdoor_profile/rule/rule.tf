# rule.tf
# Placeholder for azurerm_cdn_frontdoor_rule resource implementation

resource "azurerm_cdn_frontdoor_rule" "rule" {
  name = azurecaf_name.rule.result
  cdn_frontdoor_rule_set_id = coalesce(
    try(var.settings.cdn_frontdoor_rule_set_id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[var.settings.rule_set_key].id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[try(var.settings.rule_set.lz_key, var.client_config.landingzone_key)][var.settings.rule_set.key].id, null)
  )
  order             = var.settings.order
  behavior_on_match = try(var.settings.behavior_on_match, "Continue")
  dynamic "actions" {
    for_each = try(var.settings.actions, [])
    content {
      dynamic "url_rewrite_action" {
        for_each = try(actions.value.url_rewrite_action, [])
        content {
          destination             = try(url_rewrite_action.value.destination, null)
          source_pattern          = try(url_rewrite_action.value.source_pattern, null)
          preserve_unmatched_path = try(url_rewrite_action.value.preserve_unmatched_path, false)
        }

      }


    }
  }
  dynamic "conditions" {
    for_each = try(var.settings.conditions, [])
    content {
      # Aquí se deben mapear los bloques de condición según la estructura de settings.conditions
      # Ejemplo: host_name_condition, request_method_condition, etc.
      # El usuario debe completar según su caso de uso
    }
  }
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
