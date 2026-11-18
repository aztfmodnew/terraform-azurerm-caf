mock_provider "azurerm" {}
mock_provider "azurecaf" {}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_user"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_notification_recipient_user.resource.timeouts == null && endswith(output.api_management_id, "/local-apim") && output.user_id == "local-user"
    error_message = "Explicit null must not introduce timeout overrides or change user resolution."
  }
}
variables {
  client_config = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/local-apim" } }
      remote = { gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim" } }
    }
    api_management_users = {
      local  = { operator = { user_id = "local-user" } }
      remote = { operator = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim/users/remote-user" } }
    }
  }
  settings = {
    notification_type = "AccountClosedPublisher"
    api_management    = { key = "gateway" }
    user              = { key = "operator" }
  }
}
run "local_parent_and_user_identifier" {
  command = plan
  assert {
    condition     = azurerm_api_management_notification_recipient_user.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_notification_recipient_user"
  }
  assert {
    condition     = endswith(output.api_management_id, "/local-apim") && output.user_id == "local-user" && output.notification_type == "AccountClosedPublisher"
    error_message = "Recipient must use the APIM-local user identifier, not its ARM ID."
  }
}
run "cross_landing_zone_and_legacy_user_arm_id" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_user"
  }
  variables {
    settings = merge(var.settings, {
      api_management = { key = "gateway", lz_key = "remote" }
      user           = { key = "operator", lz_key = "remote" }
    })
  }
  assert {
    condition     = endswith(output.api_management_id, "/remote-apim") && output.user_id == "remote-user"
    error_message = "Cross-zone user references must accept existing CAF user outputs exposing only an ARM ID."
  }
}
run "direct_identifiers_and_supported_timeouts" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_user"
  }
  variables {
    settings = merge(var.settings, {
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/explicit-apim"
      api_management    = { key = "missing" }
      user_id           = "explicit-user"
      user              = { key = "missing" }
      timeouts          = { create = null, read = "6m", delete = "42m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_id, "/explicit-apim") && output.user_id == "explicit-user" && azurerm_api_management_notification_recipient_user.resource.timeouts.create == "30m" && azurerm_api_management_notification_recipient_user.resource.timeouts.delete == "42m"
    error_message = "Direct identifiers must override keys and create/read/delete timeouts must pass through."
  }
}
