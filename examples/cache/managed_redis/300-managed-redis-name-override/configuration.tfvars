# Manual-only example: name_override preserves an exact existing Azure name.
# This directory is intentionally excluded from CI/CD workflow matrices.

global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  managed_redis_override_rg = {
    name = "managed-redis-override-test"
  }
}

cache = {
  managed_redis = {
    orders_redis = {
      # Logical CAF input name retained for module compatibility.
      name = "orders-cache"

      # Exact physical Azure Managed Redis name. This is intentionally not
      # generated or modified by CAF naming because it represents an existing resource.
      name_override = "redis-orders-prod-001"

      resource_group_key        = "managed_redis_override_rg"
      sku_name                  = "Balanced_B3"
      high_availability_enabled = true
      public_network_access     = "Enabled"

      identity = {
        type = "SystemAssigned"
      }

      default_database = {
        access_keys_authentication_enabled = true
        client_protocol                    = "Encrypted"
        eviction_policy                    = "AllKeysLRU"
      }

      tags = {
        environment = "prod"
        purpose     = "managed-redis-name-override-example"
      }
    }
  }
}
