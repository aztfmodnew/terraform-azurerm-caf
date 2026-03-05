global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  redis_region1 = {
    name = "managed-redis-pe-test"
  }
}

cache = {
  managed_redis = {
    redis_pe_1 = {
      name               = "managed-redis-pe-1"
      resource_group_key = "redis_region1"

      sku_name                  = "Balanced_B3"
      high_availability_enabled = true
      public_network_access     = "Disabled"

      identity = {
        type = "SystemAssigned"
      }

      default_database = {
        access_keys_authentication_enabled = true
        client_protocol                    = "Encrypted"
        eviction_policy                    = "AllKeysLRU"
      }

      private_endpoints = {
        pe1 = {
          name               = "managed-redis-pe1"
          resource_group_key = "redis_region1"
          vnet_key           = "vnet1"
          subnet_key         = "pep"

          private_service_connection = {
            name                 = "managed-redis-psc"
            is_manual_connection = false
            subresource_names    = ["redisEnterprise"]
          }

          private_dns = {
            zone_group_name = "managed-redis"
            keys            = ["managed_redis_dns"]
          }
        }
      }

      tags = {
        environment = "dev"
        purpose     = "private-endpoint-example"
      }
    }
  }
}

vnets = {
  vnet1 = {
    resource_group_key = "redis_region1"
    vnet = {
      name          = "managed-redis-vnet"
      address_space = ["10.70.0.0/24"]
    }

    specialsubnets = {}

    subnets = {
      pep = {
        name                              = "pep"
        cidr                              = ["10.70.0.0/27"]
        private_endpoint_network_policies = "Enabled"
      }
    }
  }
}

network_security_group_definition = {
  empty_nsg = {}
}

private_dns = {
  managed_redis_dns = {
    name               = "privatelink.redisenterprise.cache.azure.net"
    resource_group_key = "redis_region1"
    vnet_links = {
      vnlnk1 = {
        name     = "managed-redis"
        vnet_key = "vnet1"
      }
    }
  }
}
