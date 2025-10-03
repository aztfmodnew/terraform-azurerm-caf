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
      cidrs = concat(
        try(destination.value.cidrs, []),
        # Translate any referenced public_ip_address keys into CIDR strings.
        # The remote object may return a bare IPv4 address (e.g. 1.2.3.4) which
        # the provider expects as a CIDR (use /32). Preserve already-valid CIDRs.
        try([
          for ip in try([
            for k in try(destination.value.public_ip_address_keys, []) : try(
              var.remote_objects.public_ip_addresses[try(try(k.lz_key, null), var.client_config.landingzone_key)][try(k.key, k)].ip_address,
              try(var.remote_objects.public_ip_addresses[var.client_config.landingzone_key][try(k.key, k)].ip_address, null)
            )
          ], []) : contains(ip, "/") ? ip : "${ip}/32" if ip != null
        ], [])
      )
      countries                       = try(destination.value.countries, null)
      feeds                           = try(destination.value.feeds, null)
      local_rulestack_fqdn_list_ids   = try(destination.value.local_rulestack_fqdn_list_ids, null)
      local_rulestack_prefix_list_ids = try(destination.value.local_rulestack_prefix_list_ids, null)
      # Note: examples may provide `public_ip_address_keys` which we translate into `cidrs` above.
    }
  }

  enabled                   = try(each.value.enabled, true)
  inspection_certificate_id = try(each.value.inspection_certificate_id, null) # Was inspection_certificate_name
  logging_enabled           = try(each.value.logging_enabled, false)          # Replaces enable_logging_destination and enable_logging_source
  negate_destination        = try(each.value.negate_destination, false)
  negate_source             = try(each.value.negate_source, false)

  # Normalize protocol vs protocol_ports.
  # If examples pass protocol_ports=["any"] we translate to the provider-accepted
  # value "application-default" and clear protocol_ports. Otherwise prefer
  # explicit protocol (if present) or leave protocol null and pass protocol_ports through.
  protocol = contains(try(each.value.protocol_ports, []), "any") ? "application-default" : try(each.value.protocol, null)

  protocol_ports = contains(try(each.value.protocol_ports, []), "any") ? null : try(each.value.protocol_ports, null)

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
