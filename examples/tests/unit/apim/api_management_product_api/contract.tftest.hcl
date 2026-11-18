mock_provider "azurerm" {}
mock_provider "azurecaf" {}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { parent = { name = "local-apim" } }
      remote = { parent = { name = "remote-apim" } }
    }
    resource_groups = {
      local  = { parent = { name = "local-rg" } }
      remote = { parent = { name = "remote-rg" } }
    }
    api_management_api = {
      local  = { parent = { name = "local-api" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/remote-api" } }
    }
    api_management_product = {
      local  = { parent = { product_id = "local-product" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/products/remote-product" } }
    }
  }
}
run "local_parent_names_and_short_product_id" {
  command = plan
  module { source = "../modules/apim/api_management_product_api" }
  variables {
    settings = { api = { key = "parent" }, product = { key = "parent" }, api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.api_name == "local-api" && output.product_id == "local-product" && azurerm_api_management_product_api.resource.api_management_name == "local-apim" && azurerm_api_management_product_api.resource.resource_group_name == "local-rg"
    error_message = "Local associations must use short product IDs, not product ARM IDs."
  }
}
run "remote_id_only_parents_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_product_api" }
  variables {
    settings = { api = { key = "parent", lz_key = "remote" }, product = { key = "parent", lz_key = "remote" }, api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", delete = "42m" } }
  }
  assert {
    condition     = output.api_name == "remote-api" && output.product_id == "remote-product" && azurerm_api_management_product_api.resource.api_management_name == "remote-apim" && azurerm_api_management_product_api.resource.resource_group_name == "remote-rg" && azurerm_api_management_product_api.resource.timeouts.delete == "42m"
    error_message = "Remote ARM IDs must become short identifiers and immutable association timeouts must pass through."
  }
}
run "direct_names_override_missing_references" {
  command = plan
  module { source = "../modules/apim/api_management_product_api" }
  variables {
    settings = { api_name = "direct-api", product_id = "direct-product", api_management_name = "direct-apim", resource_group_name = "direct-rg", api = { key = "missing" }, product = { key = "missing" }, api_management = { key = "missing" }, resource_group = { key = "missing" }, timeouts = null }
  }
  assert {
    condition     = output.api_name == "direct-api" && output.product_id == "direct-product" && azurerm_api_management_product_api.resource.api_management_name == "direct-apim" && azurerm_api_management_product_api.resource.resource_group_name == "direct-rg"
    error_message = "All direct provider arguments must override missing references."
  }
}
