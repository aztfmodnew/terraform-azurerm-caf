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
    source = "../modules/apim/api_management_workspace"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_workspace.resource.timeouts == null && endswith(output.api_management_id, "/local-apim") && output.display_name == "Example Workspace"
    error_message = "Explicit null must not introduce timeout overrides or change the workspace parent."
  }
}
variables {
  client_config = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/local-apim" } }
      remote = { gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim" } }
    }
  }
  settings = {
    name           = "example"
    display_name   = "Example Workspace"
    api_management = { key = "gateway" }
  }
}
run "local_parent_and_supported_caf_type" {
  command = plan
  assert {
    condition     = azurerm_api_management_workspace.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_workspace"
  }
  assert {
    condition     = endswith(output.api_management_id, "/local-apim") && output.name == "caf-example" && output.display_name == "Example Workspace" && azurecaf_name.resource.resource_type == "azurerm_api_management_workspace"
    error_message = "Local parent, display name and the supported workspace CAF naming type must be preserved."
  }
}
run "cross_landing_zone_and_description" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace"
  }
  variables {
    settings = merge(var.settings, {
      api_management = { key = "gateway", lz_key = "remote" }
      description    = "Remote workspace"
    })
  }
  assert {
    condition     = endswith(output.api_management_id, "/remote-apim") && azurerm_api_management_workspace.resource.description == "Remote workspace"
    error_message = "Remote parent and optional description must pass through."
  }
}
run "direct_parent_id_and_timeout_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace"
  }
  variables {
    settings = merge(var.settings, {
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/explicit-apim"
      api_management    = { key = "missing" }
      timeouts          = { create = null, update = "41m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_id, "/explicit-apim") && azurerm_api_management_workspace.resource.timeouts.create == "30m" && azurerm_api_management_workspace.resource.timeouts.update == "41m"
    error_message = "Direct IDs must override keys, nulls must use typed defaults and explicit timeouts must pass through."
  }
}
