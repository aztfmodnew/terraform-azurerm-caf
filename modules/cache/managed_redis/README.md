# Azure Managed Redis Module

This module deploys an Azure Managed Redis instance (the non-deprecated replacement for Redis Enterprise).

## Features

- ✅ **CAF Naming**: Automatic naming based on Azure CAF conventions
- ✅ **Managed Identities**: Support for system-assigned and user-assigned identities with cross-landing-zone references
- ✅ **Customer Managed Keys**: Optional encryption with customer-managed keys
- ✅ **Diagnostics**: Built-in diagnostic settings integration
- ✅ **High Availability**: Optional high availability configuration
- ✅ **Default Database**: Configurable default database settings

## Usage

### Basic Example

```hcl
module "managed_redis" {
  source   = "./modules/cache/managed_redis"
  for_each = try(local.cache.managed_redis, {})

  global_settings     = local.global_settings
  client_config       = local.client_config
  managed_redis       = each.value
  location            = try(each.value.location, null)
  resource_group_name = local.combined_objects_resource_groups[...][...].name
  base_tags           = local.combined_objects_resource_groups[...][...].tags
  remote_objects = {
    diagnostics = local.combined_diagnostics
  }
}
```

### Configuration Structure

```hcl
cache = {
  managed_redis = {
    redis1 = {
      name                      = "redis-instance-1"        # Required: unique name
      resource_group_key        = "rg_key"                  # Required: key from resource_groups
      sku_name                  = "Standard"                # Required: Standard, Premium
      high_availability_enabled = true                      # Optional: enables HA (default: true)
      public_network_access     = "Enabled"                 # Optional: Enabled/Disabled

      # Optional: System-assigned managed identity
      identity = {
        type = "SystemAssigned"
      }

      # Optional: User-assigned managed identities (same landing zone)
      # identity = {
      #   type                  = "UserAssigned"
      #   managed_identity_keys = ["identity1", "identity2"]
      # }

      # Optional: User-assigned managed identities (cross-landing-zone)
      # identity = {
      #   type   = "UserAssigned"
      #   remote = {
      #     "remote_lz_key" = {
      #       managed_identity_keys = ["identity1"]
      #     }
      #   }
      # }

      # Optional: Customer-managed encryption key
      customer_managed_key = {
        key_vault_key_id          = "/subscriptions/.../keys/mykey/version"
        user_assigned_identity_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/myidentity"
      }

      # Optional: Default database configuration
      default_database = {
        access_keys_authentication_enabled = true
        client_protocol                    = "Encrypted"      # Encrypted, Plaintext
        clustering_policy                  = null             # Optional clustering policy
        eviction_policy                    = "AllKeysLRU"    # Eviction policy (AllKeysLRU, AllKeysLFU, NoEviction, VolatileLRU, VolatileLFU, VolatileTTL, VolatileRandom)
        geo_replication_group_name         = null
        persistence_append_only_file_backup_frequency = null
        persistence_redis_database_backup_frequency   = null

        # Optional: Redis modules
        module = [{
          name = "search"
          args = "ARGS"
        }]
      }

      # Optional: Diagnostic profiles
      diagnostic_profiles = {
        operational = ["Verbose", "Http"]
      }

      # Optional: Tags
      tags = {
        environment = "dev"
      }
    }
  }
}
```

## Outputs

- `id`: The ID of the managed Redis instance
- `hostname`: The hostname of the managed Redis instance
- `default_database`: The default database configuration

## Managed Identities Pattern

This module uses a dedicated `managed_identities.tf` file to handle identity resolution:

1. **Local Identities**: Resolves managed identities from the same landing zone using keys
2. **Remote Identities**: Resolves managed identities from other landing zones
3. **Concatenation**: Combines both local and remote identities for the `identity_ids`

This enables:

- ✅ Simple same-zone references: `managed_identity_keys = ["identity1"]`
- ✅ Cross-landing-zone references: `remote = { "lz_key" = { managed_identity_keys = [...] } }`
- ✅ Direct ID references (if needed)

## Notes

- The `sku_name` argument is required and must be `Standard` or `Premium`
- High availability is enabled by default but can be disabled
- Customer-managed keys require a user-assigned identity
- Managed identities are resolved from `var.remote_objects.managed_identities`
- Diagnostics integration is automatic if diagnostic profiles are specified
