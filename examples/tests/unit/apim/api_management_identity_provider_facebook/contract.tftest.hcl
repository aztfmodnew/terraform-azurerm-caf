mock_provider "azurerm" {}
mock_provider "azurecaf" {}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_facebook"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_identity_provider_facebook.resource.timeouts == null && output.api_management_name == "local-apim" && output.resource_group_name == "local-rg"
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
    app_id         = "123456789012345"
    app_secret     = "mock-only-not-a-credential"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
run "local_parents_and_application" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_facebook"
  }
  assert {
    condition     = output.api_management_name == "local-apim" && output.resource_group_name == "local-rg" && output.app_id == "123456789012345" && azurerm_api_management_identity_provider_facebook.resource.timeouts == null
    error_message = "Application ID and local parents must pass through without overriding provider timeouts when omitted."
  }
}
run "cross_landing_zone_parents" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_facebook"
  }
  variables {
    settings = merge(var.settings, {
      api_management = { key = "gateway", lz_key = "remote" }
      resource_group = { key = "gateway", lz_key = "remote" }
    })
  }
  assert {
    condition     = output.api_management_name == "remote-apim" && output.resource_group_name == "remote-rg"
    error_message = "Both parents must resolve in the requested landing zone."
  }
}
run "explicit_parent_names_and_timeouts" {
  command = plan
  module {
    source = "../modules/apim/api_management_identity_provider_facebook"
  }
  variables {
    settings = merge(var.settings, {
      api_management_name = "explicit-apim"
      resource_group_name = "explicit-rg"
      timeouts            = { create = null, update = "41m" }
    })
  }
  assert {
    condition     = output.api_management_name == "explicit-apim" && output.resource_group_name == "explicit-rg" && azurerm_api_management_identity_provider_facebook.resource.timeouts.create == "30m" && azurerm_api_management_identity_provider_facebook.resource.timeouts.update == "41m"
    error_message = "Direct names must win; omitted and null timeout members must use typed defaults."
  }
}
