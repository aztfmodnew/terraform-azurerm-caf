global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  test_rg = {
    name = "managed-redis-test"
  }
}

cache = {
  managed_redis = {
    redis1 = {
      name               = "redis-instance-1"
      resource_group_key = "test_rg"

      # Required: SKU for managed Redis
      sku_name = "Standard"

      # Optional: Enable high availability
      high_availability_enabled = true

      # Optional: Public network access
      public_network_access = "Enabled"

      # Optional: Identity configuration
      # Supports both local (same landing zone) and remote (cross-landing-zone) managed identities
      identity = {
        type = "SystemAssigned"
        # For user-assigned identities, use:
        # type = "UserAssigned"
        # managed_identity_keys = ["key1", "key2"]  # Keys from local landing zone
        # Or for cross-landing-zone:
        # remote = {
        #   "remote_lz_key" = {
        #     managed_identity_keys = ["key1"]
        #   }
        # }
      }

      # Optional: Default database configuration
      default_database = {
        access_keys_authentication_enabled = true
        client_protocol                    = "Encrypted"
        eviction_policy                    = "AllKeysLRU"
      }

      tags = {
        environment = "dev"
        purpose     = "testing"
      }
    }
  }
}
