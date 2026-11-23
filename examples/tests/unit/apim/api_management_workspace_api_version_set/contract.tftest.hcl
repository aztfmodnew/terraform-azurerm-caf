mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-example" }
  }
}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_api_version_set"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_workspace_api_version_set.resource.timeouts == null && endswith(output.api_management_workspace_id, "/local-team") && output.versioning_scheme == "Segment"
    error_message = "Explicit null must not introduce timeout overrides or change the workspace versioning scheme."
  }
}
variables {
  client_config = { landingzone_key = "local" }
  remote_objects = {
    api_management_workspace = {
      local  = { team = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/local-team" } }
      remote = { team = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/remote-team" } }
    }
  }
  settings = {
    name                     = "example"
    display_name             = "Example Version Set"
    versioning_scheme        = "Segment"
    api_management_workspace = { key = "team" }
  }
}
run "local_workspace_and_documented_caf_fallback" {
  command = plan
  assert {
    condition     = azurerm_api_management_workspace_api_version_set.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_workspace_api_version_set"
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/local-team") && output.name == "caf-example" && output.versioning_scheme == "Segment" && azurecaf_name.resource.resource_type == "azurerm_api_management_api_version_set"
    error_message = "Local workspace and supported service-level CAF fallback must be used."
  }
}
run "remote_workspace_and_header_versioning" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_api_version_set"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace = { key = "team", lz_key = "remote" }
      versioning_scheme        = "Header"
      version_header_name      = "api-version"
      description              = "Header-based versioning"
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/remote-team") && azurerm_api_management_workspace_api_version_set.resource.version_header_name == "api-version" && azurerm_api_management_workspace_api_version_set.resource.description == "Header-based versioning"
    error_message = "Remote workspace and optional header and description must pass through."
  }
}
run "direct_workspace_and_query_versioning" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_api_version_set"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/explicit-team"
      api_management_workspace    = { key = "missing" }
      versioning_scheme           = "Query"
      version_query_name          = "api-version"
      timeouts                    = { create = null, update = "41m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/explicit-team") && azurerm_api_management_workspace_api_version_set.resource.version_query_name == "api-version" && azurerm_api_management_workspace_api_version_set.resource.timeouts.create == "30m" && azurerm_api_management_workspace_api_version_set.resource.timeouts.update == "41m"
    error_message = "Explicit workspace IDs must win; query versioning and timeouts must pass through."
  }
}
