mock_provider "azurerm" {}

run "user_supports_optional_provider_options_and_timeouts" {
  command = plan

  module {
    source = "../modules/apim/api_management_user"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      user_id      = "5931a75ae4bbd512288c680b"
      email        = "user@example.invalid"
      first_name   = "Contract"
      last_name    = "User"
      confirmation = "invite"
      note         = "Created by the focused module contract"
      password     = "Contract-password-123"
      state        = "blocked"
      timeouts = {
        create = "50m"
        read   = "6m"
        update = "50m"
        delete = "50m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_user.apim.user_id == "5931a75ae4bbd512288c680b" &&
      azurerm_api_management_user.apim.email == "user@example.invalid" &&
      azurerm_api_management_user.apim.first_name == "Contract" &&
      azurerm_api_management_user.apim.last_name == "User" &&
      azurerm_api_management_user.apim.confirmation == "invite" &&
      azurerm_api_management_user.apim.note == "Created by the focused module contract" &&
      nonsensitive(azurerm_api_management_user.apim.password) == "Contract-password-123" &&
      azurerm_api_management_user.apim.state == "blocked" &&
      azurerm_api_management_user.apim.timeouts.update == "50m"
    )
    error_message = "The user module must pass all provider options, preserve password sensitivity, and configure all timeouts."
  }
}

run "user_preserves_optional_provider_defaults" {
  command = plan

  module {
    source = "../modules/apim/api_management_user"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      user_id    = "5931a75ae4bbd512288c680c"
      email      = "defaults@example.invalid"
      first_name = "Default"
      last_name  = "User"
    }
  }

  assert {
    condition = (
      azurerm_api_management_user.apim.confirmation == null &&
      azurerm_api_management_user.apim.note == null &&
      azurerm_api_management_user.apim.password == null
    )
    error_message = "Omitted optional user settings must remain unset."
  }
}

run "user_rejects_unsupported_confirmation" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_user"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      user_id      = "5931a75ae4bbd512288c680d"
      email        = "confirmation@example.invalid"
      first_name   = "Invalid"
      last_name    = "Confirmation"
      confirmation = "email"
    }
  }
}

run "user_rejects_unsupported_state" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_user"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      user_id    = "5931a75ae4bbd512288c680e"
      email      = "state@example.invalid"
      first_name = "Invalid"
      last_name  = "State"
      state      = "submitted"
    }
  }
}
