mock_provider "azurerm" {}
mock_provider "azurecaf" {}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_aadb2c"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_identity_provider_aadb2c.resource.timeouts == null && output.api_management_name == "local-apim" && output.resource_group_name == "local-rg"
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
    client_id      = "00000000-0000-0000-0000-000000000001"
    client_secret  = "mock-only-not-a-credential"
    allowed_tenant = "example.onmicrosoft.com"
    signin_tenant  = "example.onmicrosoft.com"
    authority      = "example.b2clogin.com"
    signin_policy  = "B2C_1_Login"
    signup_policy  = "B2C_1_Signup"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
run "local_parents_and_required_policies" {
  command = plan
  assert {
    condition     = azurerm_api_management_identity_provider_aadb2c.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_identity_provider_aadb2c"
  }
  assert {
    condition     = output.api_management_name == "local-apim" && output.resource_group_name == "local-rg" && azurerm_api_management_identity_provider_aadb2c.resource.signin_policy == "B2C_1_Login" && azurerm_api_management_identity_provider_aadb2c.resource.password_reset_policy == null
    error_message = "Local parents and required B2C policies must pass through; optional policies stay null."
  }
}
run "remote_parents_and_all_optional_policies" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_aadb2c"
  }
  variables {
    settings = merge(var.settings, {
      api_management         = { key = "gateway", lz_key = "remote" }
      resource_group         = { key = "gateway", lz_key = "remote" }
      client_library         = "MSAL-2"
      password_reset_policy  = "B2C_1_Reset"
      profile_editing_policy = "B2C_1_Edit"
    })
  }
  assert {
    condition     = output.api_management_name == "remote-apim" && output.resource_group_name == "remote-rg" && azurerm_api_management_identity_provider_aadb2c.resource.password_reset_policy == "B2C_1_Reset" && azurerm_api_management_identity_provider_aadb2c.resource.profile_editing_policy == "B2C_1_Edit" && azurerm_api_management_identity_provider_aadb2c.resource.client_library == "MSAL-2"
    error_message = "Remote references and all optional B2C settings must pass through."
  }
}
run "explicit_parent_names_and_timeouts" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_aadb2c"
  }
  variables {
    settings = merge(var.settings, {
      api_management_name = "explicit-apim"
      resource_group_name = "explicit-rg"
      timeouts            = { update = "41m" }
    })
  }
  assert {
    condition     = output.api_management_name == "explicit-apim" && output.resource_group_name == "explicit-rg" && azurerm_api_management_identity_provider_aadb2c.resource.timeouts.update == "41m"
    error_message = "Explicit parents must win and custom timeouts must pass through."
  }
}
