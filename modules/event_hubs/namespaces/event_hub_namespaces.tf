resource "azurecaf_name" "evh" {
  name          = var.settings.name
  resource_type = "azurerm_eventhub_namespace"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_eventhub_namespace" "evh" {
  name                          = azurecaf_name.evh.result
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = var.settings.sku
  capacity                      = try(var.settings.capacity, null)
  tags                          = local.tags
  auto_inflate_enabled          = try(var.settings.auto_inflate_enabled, null)
  dedicated_cluster_id          = try(var.settings.dedicated_cluster_id, null)
  maximum_throughput_units      = try(var.settings.maximum_throughput_units, null)
  local_authentication_enabled  = try(var.settings.local_authentication_enabled, null)
  minimum_tls_version           = try(var.settings.minimum_tls_version, null)
  public_network_access_enabled = try(var.settings.public_network_access_enabled, null)

  dynamic "identity" {
    for_each = local.event_hub_identities
    content {
      type = identity.value.type
      identity_ids = contains(
        ["userassigned", "systemassigned, userassigned"],
        lower(identity.value.type)
        ) ? distinct(concat(
          local.managed_identities,
          try(identity.value.identity_ids, [])
      )) : null
    }
  }

  dynamic "network_rulesets" {
    for_each = can(var.settings.network_rulesets.default_action) ? [var.settings.network_rulesets] : []
    content {
      default_action                 = network_rulesets.value.default_action #Possible values are Allow and Deny. Defaults to Deny.
      trusted_service_access_enabled = try(network_rulesets.value.trusted_service_access_enabled, null)
      public_network_access_enabled  = try(network_rulesets.value.public_network_access_enabled, null)

      dynamic "virtual_network_rule" {
        for_each = try(network_rulesets.value.virtual_network_rule, {})
        content {
          subnet_id                                       = virtual_network_rule.value.subnet_id
          ignore_missing_virtual_network_service_endpoint = try(virtual_network_rule.value.ignore_missing_virtual_network_service_endpoint, null)
        }
      }

      dynamic "ip_rule" {
        for_each = try(network_rulesets.value.ip_rule, {})
        content {
          ip_mask = ip_rule.value.ip_mask
          action  = try(ip_rule.value.action, null)
        }
      }
    }
  }

  dynamic "network_rulesets" {
    for_each = {
      for key, ruleset in try(var.settings.network_rulesets, {}) : key => ruleset
      if !can(var.settings.network_rulesets.default_action)
    }
    content {
      default_action                 = network_rulesets.value.default_action
      trusted_service_access_enabled = try(network_rulesets.value.trusted_service_access_enabled, null)
      public_network_access_enabled  = try(network_rulesets.value.public_network_access_enabled, null)

      dynamic "virtual_network_rule" {
        for_each = try(network_rulesets.value.virtual_network_rule, {})
        content {
          subnet_id                                       = virtual_network_rule.value.subnet_id
          ignore_missing_virtual_network_service_endpoint = try(virtual_network_rule.value.ignore_missing_virtual_network_service_endpoint, null)
        }
      }

      dynamic "ip_rule" {
        for_each = try(network_rulesets.value.ip_rule, {})
        content {
          ip_mask = ip_rule.value.ip_mask
          action  = try(ip_rule.value.action, null)
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
