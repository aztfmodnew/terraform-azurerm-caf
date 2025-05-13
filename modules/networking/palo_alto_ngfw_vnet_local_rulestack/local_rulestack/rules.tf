resource "azurerm_palo_alto_local_rulestack_rule" "rule" {
  for_each = try(var.settings.rules, {})

  name         = each.key
  rulestack_id = azurerm_palo_alto_local_rulestack.rulestack.id
  priority     = each.value.priority
  action       = each.value.action

  applications = try(each.value.applications, null)

  audit_comment = try(each.value.audit_comment, null)
  category_url  = try(each.value.category_url, null)
  # decimal_custom_url_category = try(each.value.decimal_custom_url_category, null) # This seems to be an incorrect argument name based on typical Azure resource naming
  description = try(each.value.description, null)

  dynamic "destination" {
    for_each = try(each.value.destination, null) == null ? [] : [each.value.destination]
    content {
      addresses    = try(destination.value.addresses, null)
      fqdn_lists   = try(destination.value.fqdn_lists, null)
      prefix_lists = try(destination.value.prefix_lists, null)
      ports        = try(destination.value.ports, null)
    }
  }
  # Old direct arguments - to be deprecated based on provider version if destination block is preferred
  destination_addresses    = try(each.value.destination_addresses, null)
  destination_ports        = try(each.value.destination_ports, null)
  destination_fqdn_lists   = try(each.value.destination_fqdn_lists, null)
  destination_prefix_lists = try(each.value.destination_prefix_lists, null)

  enable_logging_destination  = try(each.value.enable_logging_destination, null)
  enable_logging_source       = try(each.value.enable_logging_source, null)
  enabled                     = try(each.value.enabled, true)
  inspection_certificate_name = try(each.value.inspection_certificate_name, null)
  negate_destination          = try(each.value.negate_destination, false)
  negate_source               = try(each.value.negate_source, false)
  protocol                    = try(each.value.protocol, null)
  protocol_ports              = try(each.value.protocol_ports, null)

  dynamic "source" {
    for_each = try(each.value.source, null) == null ? [] : [each.value.source]
    content {
      addresses    = try(source.value.addresses, null)
      fqdn_lists   = try(source.value.fqdn_lists, null)
      prefix_lists = try(source.value.prefix_lists, null)
    }
  }
  # Old direct arguments - to be deprecated
  source_addresses    = try(each.value.source_addresses, null)
  source_fqdn_lists   = try(each.value.source_fqdn_lists, null)
  source_prefix_lists = try(each.value.source_prefix_lists, null)

  tags       = try(each.value.tags, null) # Individual rule tags, if supported and needed
  rule_state = try(each.value.rule_state, null)

  # Explicitly set default for boolean if not provided and API expects it
  # enabled = try(each.value.enabled, true) # Example, adjust based on actual defaults
}
