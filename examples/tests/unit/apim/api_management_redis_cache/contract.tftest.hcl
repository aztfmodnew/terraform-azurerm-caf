mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-cache" }
  }
}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/local-apim" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim" } }
    }
    redis_caches = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Cache/redis/local-cache", primary_connection_string = "local-cache.example:6380,ssl=True" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Cache/redis/remote-cache", primary_connection_string = "remote-cache.example:6380,ssl=True" } }
    }
  }
}
run "optional_backing_id_and_default_cache_location" {
  command = plan
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = { name = "cache", connection_string = "example.redis.cache.windows.net:6380,ssl=True", api_management = { key = "parent" } }
  }
  assert {
    condition     = output.name == "caf-cache" && output.redis_cache_id == null && azurerm_api_management_redis_cache.resource.cache_location == "default" && endswith(azurerm_api_management_redis_cache.resource.api_management_id, "/service/local-apim")
    error_message = "Backing Redis ID must remain optional; CAF name and default cache location must resolve."
  }
}
run "remote_backing_cache_and_all_optionals" {
  command = plan
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = { name = "cache", connection_string = "example.redis.cache.windows.net:6380,ssl=True", api_management = { key = "parent", lz_key = "remote" }, redis_cache = { key = "parent", lz_key = "remote" }, cache_location = "westeurope", description = "Regional cache", timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = endswith(output.redis_cache_id, "/redis/remote-cache") && endswith(azurerm_api_management_redis_cache.resource.api_management_id, "/service/remote-apim") && azurerm_api_management_redis_cache.resource.cache_location == "westeurope" && azurerm_api_management_redis_cache.resource.description == "Regional cache" && nonsensitive(azurerm_api_management_redis_cache.resource.connection_string) == "example.redis.cache.windows.net:6380,ssl=True" && azurerm_api_management_redis_cache.resource.timeouts.update == "41m"
    error_message = "Remote cache IDs, connection string, regional settings and timeouts must pass through."
  }
}
run "direct_ids_and_null_location_default" {
  command = plan
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = {
      name              = "cache", connection_string = "example.redis.cache.windows.net:6380,ssl=True"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim"
      redis_cache_id    = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Cache/redis/direct-cache"
      api_management    = { key = "missing" }, redis_cache = { key = "missing" }, cache_location = null, description = null, timeouts = null
    }
  }
  assert {
    condition     = endswith(output.redis_cache_id, "/redis/direct-cache") && endswith(azurerm_api_management_redis_cache.resource.api_management_id, "/service/direct-apim") && azurerm_api_management_redis_cache.resource.cache_location == "default"
    error_message = "Explicit IDs must win; explicit null cache_location must retain the default."
  }
}
run "local_backing_cache_reference" {
  command = plan
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = { name = "cache", connection_string = "example.redis.cache.windows.net:6380,ssl=True", api_management = { key = "parent" }, redis_cache = { key = "parent" } }
  }
  assert {
    condition     = endswith(output.redis_cache_id, "/redis/local-cache")
    error_message = "A backing cache key without lz_key must use the current landing zone."
  }
}
run "managed_local_connection_string" {
  command = plan
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = { name = "cache", api_management = { key = "parent" }, redis_cache = { key = "parent" } }
  }
  assert {
    condition     = nonsensitive(azurerm_api_management_redis_cache.resource.connection_string) == "local-cache.example:6380,ssl=True"
    error_message = "An omitted direct connection string must resolve the managed local cache output."
  }
}
run "managed_remote_connection_string" {
  command = plan
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = { name = "cache", connection_string = null, api_management = { key = "parent" }, redis_cache = { key = "parent", lz_key = "remote" } }
  }
  assert {
    condition     = nonsensitive(azurerm_api_management_redis_cache.resource.connection_string) == "remote-cache.example:6380,ssl=True"
    error_message = "An explicit null connection string must resolve the selected remote landing zone."
  }
}
run "reject_missing_connection_source" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_redis_cache" }
  variables {
    settings = { name = "cache", api_management = { key = "parent" } }
  }
}
