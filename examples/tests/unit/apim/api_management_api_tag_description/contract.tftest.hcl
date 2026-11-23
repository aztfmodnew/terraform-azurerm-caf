mock_provider "azurerm" {}
mock_provider "azurecaf" {}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management_api_tag = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/local-api/tags/tag" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/remote-api/tags/tag" } }
    }
  }
}
run "local_api_tag_association" {
  command = plan
  module { source = "../modules/apim/api_management_api_tag_description" }
  variables {
    settings = { api_tag = { key = "parent" } }
  }
  assert {
    condition     = endswith(output.api_tag_id, "/apis/local-api/tags/tag")
    error_message = "Description must attach to an API tag, not a service-level tag."
  }
}
run "remote_reference_and_all_descriptions" {
  command = plan
  module { source = "../modules/apim/api_management_api_tag_description" }
  variables {
    settings = {
      api_tag     = { key = "parent", lz_key = "remote" }
      description = "Orders", external_documentation_url = "https://example.com/orders", external_documentation_description = "Order documentation"
      timeouts    = { create = "40m", read = "6m", update = "41m", delete = "42m" }
    }
  }
  assert {
    condition     = endswith(output.api_tag_id, "/apis/remote-api/tags/tag") && azurerm_api_management_api_tag_description.resource.description == "Orders" && azurerm_api_management_api_tag_description.resource.external_documentation_url == "https://example.com/orders" && azurerm_api_management_api_tag_description.resource.external_documentation_description == "Order documentation" && azurerm_api_management_api_tag_description.resource.timeouts.update == "41m"
    error_message = "Remote API tag and all description fields/timeouts must pass through."
  }
}
run "direct_id_and_null_optionals" {
  command = plan
  module { source = "../modules/apim/api_management_api_tag_description" }
  variables {
    settings = { api_tag_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/direct-api/tags/tag", api_tag = { key = "missing" }, description = null, external_documentation_url = null, external_documentation_description = null, timeouts = null }
  }
  assert {
    condition     = endswith(output.api_tag_id, "/apis/direct-api/tags/tag")
    error_message = "Direct IDs must override missing keys and null optional fields must be accepted."
  }
}
