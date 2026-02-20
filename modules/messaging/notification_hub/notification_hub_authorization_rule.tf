# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/notification_hub_authorization_rule

resource "azurerm_notification_hub_authorization_rule" "notification_hub_authorization_rule" {
  for_each = {
    for composite_key, value in flatten([
      for hub_key, hub in try(var.settings.hubs, {}) : [
        for rule_key, rule in try(hub.authorization_rules, {}) : {
          key      = "${hub_key}_${rule_key}"
          hub_key  = hub_key
          rule_key = rule_key
          rule     = rule
        }
      ]
    ]) : value.key => value
  }

  name                  = each.value.rule.name
  notification_hub_name = azurerm_notification_hub.notification_hub[each.value.hub_key].name
  namespace_name        = azurerm_notification_hub_namespace.notification_hub_namespace.name
  resource_group_name   = local.resource_group_name
  manage                = try(each.value.rule.manage, false)
  send                  = try(each.value.rule.send, false)
  listen                = try(each.value.rule.listen, false)
}
