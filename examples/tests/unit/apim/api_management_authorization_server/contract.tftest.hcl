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
    source = "../modules/apim/api_management_authorization_server"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_authorization_server.resource.timeouts == null && output.api_management_name == "local-apim" && output.resource_group_name == "local-rg"
    error_message = "Explicit null must not introduce timeout overrides or change parent resolution."
  }
}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { gateway = { name = "local-apim" } }
      remote = { gateway = { name = "remote-apim" } }
    }
    resource_groups = {
      local  = { gateway = { name = "local-rg" } }
      remote = { gateway = { name = "remote-rg" } }
    }
  }
  settings = {
    name                         = "example"
    display_name                 = "Example"
    authorization_endpoint       = "https://example.com/authorize"
    authorization_methods        = ["GET", "POST"]
    client_id                    = "00000000-0000-0000-0000-000000000001"
    client_registration_endpoint = "https://example.com/register"
    grant_types                  = ["authorizationCode"]
    api_management               = { key = "gateway" }
    resource_group               = { key = "gateway" }
  }
}
run "local_parents_and_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_authorization_server"
  }
  assert {
    condition     = output.api_management_name == "local-apim" && output.resource_group_name == "local-rg" && output.name == "caf-example" && azurerm_api_management_authorization_server.resource.timeouts == null
    error_message = "Local references and CAF naming must be preserved without adding a timeout override when omitted."
  }
}
run "cross_landing_zone_and_nested_parameters" {
  command = plan
  module {
    source = "../modules/apim/api_management_authorization_server"
  }
  variables {
    settings = merge(var.settings, {
      api_management       = { key = "gateway", lz_key = "remote" }
      resource_group       = { key = "gateway", lz_key = "remote" }
      token_body_parameter = [{ name = "audience", value = "https://example.com" }]
      support_state        = true
      token_endpoint       = "https://example.com/token"
    })
  }
  assert {
    condition     = output.api_management_name == "remote-apim" && output.resource_group_name == "remote-rg" && one(azurerm_api_management_authorization_server.resource.token_body_parameter).name == "audience" && azurerm_api_management_authorization_server.resource.support_state
    error_message = "Remote parents and nested token parameters must pass through."
  }
}
run "explicit_parents_and_timeouts_override_references" {
  command = plan
  module {
    source = "../modules/apim/api_management_authorization_server"
  }
  variables {
    settings = merge(var.settings, {
      api_management_name = "explicit-apim"
      resource_group_name = "explicit-rg"
      timeouts            = { create = "40m", read = "6m", update = "41m", delete = "42m" }
    })
  }
  assert {
    condition     = output.api_management_name == "explicit-apim" && output.resource_group_name == "explicit-rg" && azurerm_api_management_authorization_server.resource.timeouts.update == "41m"
    error_message = "Explicit names must win over references and custom timeouts must pass through."
  }
}
