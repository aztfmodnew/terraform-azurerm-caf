mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-release" }
  }
}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management_api = {
      local  = { api = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/local-api;rev=2" } }
      remote = { api = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/remote-api;rev=2" } }
    }
  }
}
run "local_api_and_caf_name" {
  command = plan
  module { source = "../modules/apim/api_management_api_release" }
  variables {
    settings = { name = "release", api = { key = "api" } }
  }
  assert {
    condition     = endswith(output.api_id, "/apis/local-api;rev=2") && output.name == "caf-release"
    error_message = "Local API revision and CAF release name must resolve."
  }
}
run "remote_api_and_notes" {
  command = plan
  module { source = "../modules/apim/api_management_api_release" }
  variables {
    settings = { name = "release", api = { key = "api", lz_key = "remote" }, notes = "Promote revision two", timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = endswith(output.api_id, "/apis/remote-api;rev=2") && azurerm_api_management_api_release.resource.notes == "Promote revision two" && azurerm_api_management_api_release.resource.timeouts.update == "41m"
    error_message = "Remote API, release notes and supported timeouts must pass through."
  }
}
run "direct_id_overrides_missing_reference" {
  command = plan
  module { source = "../modules/apim/api_management_api_release" }
  variables {
    settings = { name = "release", api_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/direct-api;rev=2", api = { key = "missing" }, notes = null, timeouts = null }
  }
  assert {
    condition     = endswith(output.api_id, "/apis/direct-api;rev=2")
    error_message = "A direct ID must override a missing reference; explicit null optionals must be accepted."
  }
}
