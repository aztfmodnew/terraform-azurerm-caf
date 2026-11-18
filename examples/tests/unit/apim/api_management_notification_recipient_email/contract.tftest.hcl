mock_provider "azurerm" {}
mock_provider "azurecaf" {}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_email"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_notification_recipient_email.resource.timeouts == null && endswith(output.api_management_id, "/local-apim") && output.email == "operations@example.com"
    error_message = "Explicit null must not introduce timeout overrides or change the recipient."
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
    email             = "operations@example.com"
    notification_type = "AccountClosedPublisher"
    api_management    = { key = "gateway" }
  }
}
run "local_parent_and_recipient" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_email"
  }
  assert {
    condition     = endswith(output.api_management_id, "/local-apim") && output.email == "operations@example.com" && output.notification_type == "AccountClosedPublisher" && azurerm_api_management_notification_recipient_email.resource.timeouts == null
    error_message = "Local APIM ID, recipient and notification type must pass through without overriding omitted timeouts."
  }
}
run "cross_landing_zone_parent" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_email"
  }
  variables {
    settings = merge(var.settings, { api_management = { key = "gateway", lz_key = "remote" } })
  }
  assert {
    condition     = endswith(output.api_management_id, "/remote-apim")
    error_message = "The APIM ARM ID must resolve from the specified landing zone."
  }
}
run "direct_parent_id_and_supported_timeouts" {
  command = plan
  module {
    source = "../modules/apim/api_management_notification_recipient_email"
  }
  variables {
    settings = merge(var.settings, {
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/explicit-apim"
      api_management    = { key = "missing" }
      timeouts          = { create = null, read = "6m", delete = "42m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_id, "/explicit-apim") && azurerm_api_management_notification_recipient_email.resource.timeouts.create == "30m" && azurerm_api_management_notification_recipient_email.resource.timeouts.delete == "42m"
    error_message = "Direct IDs must override unresolved keys; only create/read/delete timeouts are supported."
  }
}
