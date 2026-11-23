mock_provider "azurerm" {}
mock_provider "azurecaf" {}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_aad"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_identity_provider_aad.resource.timeouts == null && output.api_management_name == "local-apim" && output.resource_group_name == "local-rg"
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
    client_id       = "00000000-0000-0000-0000-000000000001"
    client_secret   = "mock-only-not-a-credential"
    allowed_tenants = ["00000000-0000-0000-0000-000000000002"]
    api_management  = { key = "gateway" }
    resource_group  = { key = "gateway" }
  }
}
run "local_parents_and_optional_nulls" {
  command = plan
  assert {
    condition     = azurerm_api_management_identity_provider_aad.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_identity_provider_aad"
  }
  assert {
    condition     = output.api_management_name == "local-apim" && output.resource_group_name == "local-rg" && azurerm_api_management_identity_provider_aad.resource.client_library == null && output.allowed_tenants == tolist(["00000000-0000-0000-0000-000000000002"])
    error_message = "Local references, optional null passthrough and tenant lists must be preserved."
  }
}
run "cross_landing_zone_and_optional_attributes" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_aad"
  }
  variables {
    settings = merge(var.settings, {
      api_management = { key = "gateway", lz_key = "remote" }
      resource_group = { key = "gateway", lz_key = "remote" }
      client_library = "MSAL-2"
      signin_tenant  = "00000000-0000-0000-0000-000000000002"
    })
  }
  assert {
    condition     = output.api_management_name == "remote-apim" && output.resource_group_name == "remote-rg" && azurerm_api_management_identity_provider_aad.resource.client_library == "MSAL-2" && azurerm_api_management_identity_provider_aad.resource.signin_tenant == "00000000-0000-0000-0000-000000000002"
    error_message = "Remote references and all optional identity attributes must pass through."
  }
}
run "explicit_parent_names_and_null_timeout_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_aad"
  }
  variables {
    settings = merge(var.settings, {
      api_management_name = "explicit-apim"
      resource_group_name = "explicit-rg"
      timeouts            = { create = null, read = "6m", update = "41m", delete = "42m" }
    })
  }
  assert {
    condition     = output.api_management_name == "explicit-apim" && output.resource_group_name == "explicit-rg" && azurerm_api_management_identity_provider_aad.resource.timeouts.create == "30m" && azurerm_api_management_identity_provider_aad.resource.timeouts.update == "41m"
    error_message = "Direct names must win; explicit null timeout members must use typed defaults."
  }
}
