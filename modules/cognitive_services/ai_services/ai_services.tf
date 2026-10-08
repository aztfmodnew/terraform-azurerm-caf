resource "azurerm_cognitive_account" "ai_services" {
  name                = var.settings.name
  location            = local.location
  resource_group_name = local.resource_group_name
  kind                = "AIServices"
  sku_name            = var.settings.sku_name

  custom_subdomain_name              = try(var.settings.custom_subdomain_name, null)
  fqdns                              = try(var.settings.fqdns, null)
  local_auth_enabled                 = try(var.settings.local_auth_enabled, try(var.settings.local_authentication_enabled, true))
  outbound_network_access_restricted = try(var.settings.outbound_network_access_restricted, false)
  project_management_enabled         = try(var.settings.project_management_enabled, true)
  public_network_access_enabled      = try(var.settings.public_network_access_enabled, try(tobool(var.settings.public_network_access), lower(tostring(try(var.settings.public_network_access, "Enabled"))) == "enabled"))

  dynamic "customer_managed_key" {
    for_each = try(var.settings.customer_managed_key, null) == null ? [] : [var.settings.customer_managed_key]
    content {
      key_vault_key_id   = try(customer_managed_key.value.key_vault_key_id, null)
      identity_client_id = try(customer_managed_key.value.identity_client_id, null)
    }
  }

  lifecycle {
    precondition {
      condition     = try(var.settings.customer_managed_key.managed_hsm_key_id, null) == null
      error_message = "AzureRM 5.8 azurerm_cognitive_account supports customer_managed_key.key_vault_key_id, not managed_hsm_key_id."
    }
  }

  dynamic "network_acls" {
    for_each = try(var.settings.network_acls, null) == null ? [] : [var.settings.network_acls]
    content {
      default_action = network_acls.value.default_action
      ip_rules       = try(network_acls.value.ip_rules, null)
      dynamic "virtual_network_rules" {
        for_each = try(network_acls.value.virtual_network_rules, null) == null ? [] : network_acls.value.virtual_network_rules
        content {
          subnet_id                            = can(virtual_network_rules.value.subnet_id) || can(virtual_network_rules.value.subnet_key) ? try(virtual_network_rules.value.subnet_id, var.remote_objects.virtual_subnets[try(virtual_network_rules.value.lz_key, var.client_config.landingzone_key)][virtual_network_rules.value.subnet_key].id) : var.remote_objects.vnets[try(virtual_network_rules.value.lz_key, var.client_config.landingzone_key)][virtual_network_rules.value.vnet_key].subnets[virtual_network_rules.value.subnet_key].id
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, false)
        }
      }
    }
  }

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? (try(var.settings.project_management_enabled, true) ? [{ type = "SystemAssigned" }] : []) : [var.settings.identity]
    content {
      type         = identity.value.type
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(identity.value.type)) ? local.managed_identities : null
    }
  }

  dynamic "storage" {
    for_each = try(var.settings.storage, null) == null ? [] : [var.settings.storage]
    content {
      storage_account_id = try(coalesce(
        try(storage.value.storage_account_id, null),
        try(storage.value.storage_account.id, null),
        try(var.remote_objects.storage_accounts[try(storage.value.storage_account.lz_key, var.client_config.landingzone_key)][try(storage.value.storage_account_key, storage.value.storage_account.key)].id, null)
      ), null)
      identity_client_id = try(storage.value.identity_client_id, null)
    }
  }

  tags = merge(local.tags, try(var.settings.tags, null))

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, "30m")
      update = try(timeouts.value.update, "30m")
      read   = try(timeouts.value.read, "5m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
