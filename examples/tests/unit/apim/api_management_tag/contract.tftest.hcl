mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-tag" }
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
  }
}
run "local_parent_and_caf_tag_name" {
  command = plan
  module { source = "../modules/apim/api_management_tag" }
  variables {
    settings = { name = "tag", api_management = { key = "parent" } }
  }
  assert {
    condition     = output.name == "caf-tag" && endswith(azurerm_api_management_tag.resource.api_management_id, "/service/local-apim")
    error_message = "Service tags must generate their name through the exact supported CAF type."
  }
}
run "remote_parent_display_name_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_tag" }
  variables {
    settings = { name = "tag", display_name = "Order APIs", api_management = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = output.display_name == "Order APIs" && endswith(azurerm_api_management_tag.resource.api_management_id, "/service/remote-apim") && azurerm_api_management_tag.resource.timeouts.update == "41m"
    error_message = "Remote parent, explicit display name and timeouts must pass through."
  }
}
run "direct_parent_overrides_missing_key" {
  command = plan
  module { source = "../modules/apim/api_management_tag" }
  variables {
    settings = { name = "tag", display_name = null, api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim", api_management = { key = "missing" }, timeouts = null }
  }
  assert {
    condition     = endswith(azurerm_api_management_tag.resource.api_management_id, "/service/direct-apim") && output.name == "caf-tag"
    error_message = "Direct parent IDs must win while null display_name remains provider-defaulted."
  }
}
