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
    source = "../modules/apim/api_management_openid_connect_provider"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_openid_connect_provider.resource.timeouts == null && output.api_management_name == "local-apim" && output.resource_group_name == "local-rg"
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
    name              = "example"
    display_name      = "Example"
    client_id         = "00000000-0000-0000-0000-000000000001"
    client_secret     = "mock-only-not-a-credential"
    metadata_endpoint = "https://example.com/.well-known/openid-configuration"
    api_management    = { key = "gateway" }
    resource_group    = { key = "gateway" }
  }
}
run "local_parents_and_caf_name" {
  command = plan
  assert {
    condition     = azurerm_api_management_openid_connect_provider.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_openid_connect_provider"
  }
  assert {
    condition     = output.api_management_name == "local-apim" && output.resource_group_name == "local-rg" && output.name == "caf-example" && output.metadata_endpoint == "https://example.com/.well-known/openid-configuration"
    error_message = "Local parents, CAF naming and metadata URI must pass through."
  }
}
run "cross_landing_zone_and_description" {
  command = plan
  module {
    source = "../modules/apim/api_management_openid_connect_provider"
  }
  variables {
    settings = merge(var.settings, {
      api_management = { key = "gateway", lz_key = "remote" }
      resource_group = { key = "gateway", lz_key = "remote" }
      description    = "Example discovery provider"
    })
  }
  assert {
    condition     = output.api_management_name == "remote-apim" && output.resource_group_name == "remote-rg" && azurerm_api_management_openid_connect_provider.resource.description == "Example discovery provider"
    error_message = "Remote parents and optional description must pass through."
  }
}
run "explicit_parent_names_and_timeouts" {
  command = plan
  module {
    source = "../modules/apim/api_management_openid_connect_provider"
  }
  variables {
    settings = merge(var.settings, {
      api_management_name = "explicit-apim"
      resource_group_name = "explicit-rg"
      timeouts            = { create = null, update = "41m" }
    })
  }
  assert {
    condition     = output.api_management_name == "explicit-apim" && output.resource_group_name == "explicit-rg" && azurerm_api_management_openid_connect_provider.resource.timeouts.create == "30m" && azurerm_api_management_openid_connect_provider.resource.timeouts.update == "41m"
    error_message = "Direct names must win; omitted and null timeout members must use typed defaults."
  }
}
