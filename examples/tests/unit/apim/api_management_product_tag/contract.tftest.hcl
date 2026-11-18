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
    api_management_tag = {
      local  = { parent = { name = "existing-local-tag" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/tags/existing-remote-tag" } }
    }
    api_management_product = {
      local  = { parent = { product_id = "local-product" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/products/remote-product" } }
    }
  }
}
run "local_existing_tag_not_renamed" {
  command = plan
  module { source = "../modules/apim/api_management_product_tag" }
  variables {
    settings = { tag = { key = "parent" }, product = { key = "parent" }, api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.name == "existing-local-tag" && output.api_management_product_id == "local-product" && azurerm_api_management_product_tag.resource.api_management_name == "local-apim" && azurerm_api_management_product_tag.resource.resource_group_name == "local-rg"
    error_message = "Tag association must preserve the existing tag name and short product identifier."
  }
}
run "remote_id_only_parents_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_product_tag" }
  variables {
    settings = { tag = { key = "parent", lz_key = "remote" }, product = { key = "parent", lz_key = "remote" }, api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", delete = "42m" } }
  }
  assert {
    condition     = output.name == "existing-remote-tag" && output.api_management_product_id == "remote-product" && azurerm_api_management_product_tag.resource.api_management_name == "remote-apim" && azurerm_api_management_product_tag.resource.resource_group_name == "remote-rg" && azurerm_api_management_product_tag.resource.timeouts.delete == "42m"
    error_message = "Remote tag/product ARM IDs must resolve short names and timeouts must pass through."
  }
}
run "direct_arguments_override_missing_references" {
  command = plan
  module { source = "../modules/apim/api_management_product_tag" }
  variables {
    settings = { name = "direct-tag", api_management_product_id = "direct-product", api_management_name = "direct-apim", resource_group_name = "direct-rg", tag = { key = "missing" }, product = { key = "missing" }, api_management = { key = "missing" }, resource_group = { key = "missing" }, timeouts = null }
  }
  assert {
    condition     = output.name == "direct-tag" && output.api_management_product_id == "direct-product" && azurerm_api_management_product_tag.resource.api_management_name == "direct-apim" && azurerm_api_management_product_tag.resource.resource_group_name == "direct-rg"
    error_message = "Direct tag/product/service/resource-group arguments must override missing references."
  }
}
