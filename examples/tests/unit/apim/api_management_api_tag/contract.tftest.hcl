mock_provider "azurerm" {}
mock_provider "azurecaf" {}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management_api = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/local-api" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/remote-api" } }
    }
    api_management_tag = {
      local  = { parent = { name = "existing-local-tag" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/tags/existing-remote-tag" } }
    }
  }
}
run "local_existing_tag_not_renamed" {
  command = plan
  module { source = "../modules/apim/api_management_api_tag" }
  variables {
    settings = { api = { key = "parent" }, tag = { key = "parent" } }
  }
  assert {
    condition     = output.name == "existing-local-tag" && endswith(output.api_id, "/apis/local-api")
    error_message = "An association must use the existing tag name without generating another CAF name."
  }
}
run "remote_id_only_tag_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_api_tag" }
  variables {
    settings = { api = { key = "parent", lz_key = "remote" }, tag = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", delete = "42m" } }
  }
  assert {
    condition     = output.name == "existing-remote-tag" && endswith(output.api_id, "/apis/remote-api") && azurerm_api_management_api_tag.resource.timeouts.delete == "42m"
    error_message = "Remote tag ARM IDs must become existing names; immutable association timeouts must pass through."
  }
}
run "explicit_arguments_override_missing_references" {
  command = plan
  module { source = "../modules/apim/api_management_api_tag" }
  variables {
    settings = { api_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/direct-api", name = "direct-tag", api = { key = "missing" }, tag = { key = "missing" }, timeouts = null }
  }
  assert {
    condition     = output.name == "direct-tag" && endswith(output.api_id, "/apis/direct-api")
    error_message = "Explicit API ID and tag name must take precedence."
  }
}
