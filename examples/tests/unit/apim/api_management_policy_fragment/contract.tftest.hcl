mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-fragment" }
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
run "local_parent_and_xml_default" {
  command = plan
  module { source = "../modules/apim/api_management_policy_fragment" }
  variables {
    settings = { name = "fragment", value = "<fragment/>", api_management = { key = "parent" } }
  }
  assert {
    condition     = output.name == "caf-fragment" && output.format == "xml" && endswith(azurerm_api_management_policy_fragment.resource.api_management_id, "/service/local-apim")
    error_message = "Fragments must use CAF names, local parents and the xml default."
  }
}
run "remote_parent_and_rawxml_optionals" {
  command = plan
  module { source = "../modules/apim/api_management_policy_fragment" }
  variables {
    settings = { name = "fragment", value = "<fragment><set-header name=\"x-example\" exists-action=\"override\"><value>example</value></set-header></fragment>", format = "rawxml", description = "Reusable headers", api_management = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = output.format == "rawxml" && endswith(azurerm_api_management_policy_fragment.resource.api_management_id, "/service/remote-apim") && azurerm_api_management_policy_fragment.resource.description == "Reusable headers" && startswith(azurerm_api_management_policy_fragment.resource.value, "<fragment><set-header") && azurerm_api_management_policy_fragment.resource.timeouts.update == "41m"
    error_message = "Remote parents, rawxml payload, description and timeouts must pass through."
  }
}
run "direct_parent_and_null_format_default" {
  command = plan
  module { source = "../modules/apim/api_management_policy_fragment" }
  variables {
    settings = { name = "fragment", value = "<fragment/>", format = null, description = null, api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim", api_management = { key = "missing" }, timeouts = null }
  }
  assert {
    condition     = output.format == "xml" && endswith(azurerm_api_management_policy_fragment.resource.api_management_id, "/service/direct-apim")
    error_message = "Explicit null format must use xml and a direct parent ID must win."
  }
}
