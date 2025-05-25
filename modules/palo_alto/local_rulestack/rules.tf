resource "azurerm_palo_alto_local_rulestack_rule" "local_rulestack_rule" {
  for_each = try(var.settings.rules, {})

  name         = each.key
  rulestack_id = azurerm_palo_alto_local_rulestack.local_rulestack.id
  priority     = each.value.priority
  action       = each.value.action

  applications = each.value.applications # Required

  audit_comment = try(each.value.audit_comment, null)
  description   = try(each.value.description, null)

  dynamic "category" {
    for_each = try(each.value.category, null) == null ? [] : [each.value.category]
    content {
      custom_urls = category.value.custom_urls # Required
      feeds       = try(category.value.feeds, null)
    }
  }

  decryption_rule_type = try(each.value.decryption_rule_type, "None")

  dynamic "destination" {
    for_each = try(each.value.destination, null) == null ? [] : [each.value.destination]
    content {
      cidrs                           = try(destination.value.cidrs, null)
      countries                       = try(destination.value.countries, null)
      feeds                           = try(destination.value.feeds, null)
      local_rulestack_fqdn_list_ids   = try(destination.value.local_rulestack_fqdn_list_ids, null)
      local_rulestack_prefix_list_ids = try(destination.value.local_rulestack_prefix_list_ids, null)
    }
  }

  enabled                   = try(each.value.enabled, true)
  inspection_certificate_id = try(each.value.inspection_certificate_id, null) # Was inspection_certificate_name
  logging_enabled           = try(each.value.logging_enabled, false)          # Replaces enable_logging_destination and enable_logging_source
  negate_destination        = try(each.value.negate_destination, false)
  negate_source             = try(each.value.negate_source, false)

  # Ensure exactly one of protocol or protocol_ports is specified
  protocol       = try(each.value.protocol_ports, null) == null ? try(each.value.protocol, "application-default") : null
  protocol_ports = try(each.value.protocol_ports, null)

  dynamic "source" {
    for_each = try(each.value.source, null) == null ? [] : [each.value.source]
    content {
      cidrs                           = try(source.value.cidrs, null)
      countries                       = try(source.value.countries, null)
      feeds                           = try(source.value.feeds, null)
      local_rulestack_prefix_list_ids = try(source.value.local_rulestack_prefix_list_ids, null)
    }
  }

  tags = try(each.value.tags, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, "30m")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
