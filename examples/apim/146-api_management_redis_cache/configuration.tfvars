global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "external-cache", region = "primary" }
}
api_management = {
  gateway = {
    name           = "external-cache", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
azurerm_redis_caches = {
  external = {
    resource_group_key = "gateway"
    redis = {
      name          = "external-cache", capacity = 1, family = "C", sku_name = "Standard"
      redis_version = "6", minimum_tls_version = "1.2", non_ssl_port_enabled = false
    }
  }
}

api_management_redis_cache = {
  regional = {
    name           = "regional-cache"
    api_management = { key = "gateway" }
    redis_cache    = { key = "external" }
    cache_location = "westeurope"
    description    = "External regional cache."
    # Resolve the managed cache's primary connection string inside the module.
    # No credentials are embedded in this deployment example.
  }
}
