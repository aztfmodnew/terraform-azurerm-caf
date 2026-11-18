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
    api_management_group = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/groups/local-group" } }
      remote = { parent = { name = "remote-group" } }
    }
    api_management_product = {
      local  = { parent = { product_id = "local-product" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/products/remote-product" } }
    }
  }
}
run "local_group_name_and_short_product_id" {
  command = plan
  module { source = "../modules/apim/api_management_product_group" }
  variables {
    settings = { group = { key = "parent" }, product = { key = "parent" }, api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.group_name == "local-group" && output.product_id == "local-product" && azurerm_api_management_product_group.resource.api_management_name == "local-apim" && azurerm_api_management_product_group.resource.resource_group_name == "local-rg"
    error_message = "Group ID-only outputs must resolve to names; product_id must stay a short identifier."
  }
}
run "remote_references_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_product_group" }
  variables {
    settings = { group = { key = "parent", lz_key = "remote" }, product = { key = "parent", lz_key = "remote" }, api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", delete = "42m" } }
  }
  assert {
    condition     = output.group_name == "remote-group" && output.product_id == "remote-product" && azurerm_api_management_product_group.resource.api_management_name == "remote-apim" && azurerm_api_management_product_group.resource.resource_group_name == "remote-rg" && azurerm_api_management_product_group.resource.timeouts.delete == "42m"
    error_message = "All remote parents and immutable association timeouts must resolve."
  }
}
run "direct_arguments_override_missing_references" {
  command = plan
  module { source = "../modules/apim/api_management_product_group" }
  variables {
    settings = { group_name = "direct-group", product_id = "direct-product", api_management_name = "direct-apim", resource_group_name = "direct-rg", group = { key = "missing" }, product = { key = "missing" }, api_management = { key = "missing" }, resource_group = { key = "missing" }, timeouts = null }
  }
  assert {
    condition     = output.group_name == "direct-group" && output.product_id == "direct-product" && azurerm_api_management_product_group.resource.api_management_name == "direct-apim" && azurerm_api_management_product_group.resource.resource_group_name == "direct-rg"
    error_message = "Direct arguments must override missing references."
  }
}
