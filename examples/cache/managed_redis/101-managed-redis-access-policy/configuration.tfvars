global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  test_rg = {
    name = "managed-redis-access-policy-test"
  }
}

managed_identities = {
  redis_client = {
    name = "managed-redis-client"
    resource_group = {
      key = "test_rg"
    }
    tags = {
      environment = "dev"
      purpose     = "managed-redis-access-policy-example"
    }
  }
}

cache = {
  managed_redis = {
    redis1 = {
      name               = "access-policy-1"
      resource_group_key = "test_rg"

      sku_name                  = "Balanced_B3"
      high_availability_enabled = true
      public_network_access     = "Enabled"

      identity = {
        type = "SystemAssigned"
      }

      redis_role_assignment = {
        "Data Owner" = {
          managed_identities = {
            keys = ["redis_client"]
          }
        }
      }

      default_database = {
        access_keys_authentication_enabled = false
        client_protocol                    = "Encrypted"
        eviction_policy                    = "AllKeysLRU"
      }

      tags = {
        environment = "dev"
        purpose     = "managed-redis-access-policy-example"
      }
    }
  }
}
