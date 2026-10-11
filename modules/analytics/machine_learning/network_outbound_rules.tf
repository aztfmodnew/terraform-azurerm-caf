resource "azurerm_machine_learning_workspace_network_outbound_rule_fqdn" "rules" {
  for_each = try(local.network_outbound_rules.fqdn, {})

  name             = coalesce(try(each.value.name, null), each.key)
  workspace_id     = azurerm_machine_learning_workspace.ws.id
  destination_fqdn = each.value.destination_fqdn

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_machine_learning_workspace_network_outbound_rule_private_endpoint" "rules" {
  for_each = try(local.network_outbound_rules.private_endpoint, {})

  name                = coalesce(try(each.value.name, null), each.key)
  workspace_id        = azurerm_machine_learning_workspace.ws.id
  service_resource_id = each.value.service_resource_id
  sub_resource_target = each.value.sub_resource_target
  spark_enabled       = try(each.value.spark_enabled, null)

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_machine_learning_workspace_network_outbound_rule_service_tag" "rules" {
  for_each = try(local.network_outbound_rules.service_tag, {})

  name         = coalesce(try(each.value.name, null), each.key)
  workspace_id = azurerm_machine_learning_workspace.ws.id
  service_tag  = each.value.service_tag
  protocol     = each.value.protocol
  port_ranges  = each.value.port_ranges

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
