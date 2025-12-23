# Managed Redis (replacement for deprecated Redis Enterprise resources)
resource "azurerm_managed_redis" "managed_redis" {
  name                = azurecaf_name.managed_redis.result
  resource_group_name = local.resource_group_name
  location            = local.location

  sku_name                  = var.settings.sku_name
  high_availability_enabled = try(var.settings.high_availability_enabled, true)
  public_network_access     = try(var.settings.public_network_access, "Enabled")

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = var.settings.identity.type
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = try(var.settings.customer_managed_key, null) == null ? [] : [var.settings.customer_managed_key]

    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "default_database" {
    for_each = try(var.settings.default_database, null) == null ? [] : [var.settings.default_database]

    content {
      access_keys_authentication_enabled        = try(default_database.value.access_keys_authentication_enabled, false)
      client_protocol                           = try(default_database.value.client_protocol, null)
      clustering_policy                         = try(default_database.value.clustering_policy, null)
      eviction_policy                           = try(default_database.value.eviction_policy, null)
      geo_replication_group_name                = try(default_database.value.geo_replication_group_name, null)
      persistence_append_only_file_backup_frequency = try(default_database.value.persistence_append_only_file_backup_frequency, null)
      persistence_redis_database_backup_frequency  = try(default_database.value.persistence_redis_database_backup_frequency, null)

      dynamic "module" {
        for_each = can(default_database.value.modules) ? (
          try(length(default_database.value.modules), 0) > 0 ? default_database.value.modules : []
        ) : []

        content {
          name = module.value.name
          args = try(module.value.args, null)
        }
      }
    }
  }

  tags = merge(local.tags, try(var.settings.tags, null))

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, "45m")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
