mock_provider "azurerm" {}

variables {
  global_settings          = {}
  client_config            = { landingzone_key = "local" }
  api_management_name      = "example-apim"
  resource_group_name      = "example-rg"
  api_management_logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/loggers/monitor"
}

run "explicit_null_optional_enums_remain_provider_owned" {
  command = plan

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    settings = {
      identifier                = "azuremonitor"
      verbosity                 = null
      http_correlation_protocol = null
      operation_name_format     = null
    }
  }

  assert {
    condition = (
      var.settings.verbosity == null &&
      var.settings.http_correlation_protocol == null &&
      var.settings.operation_name_format == null &&
      azurerm_api_management_diagnostic.apim.identifier == "azuremonitor"
    )
    error_message = "Optional enums must allow explicit null without inventing module defaults."
  }
}

run "unsupported_verbosity_is_rejected" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    settings = {
      identifier = "azuremonitor"
      verbosity  = "debug"
    }
  }
}

run "unsupported_correlation_protocol_is_rejected" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    settings = {
      identifier                = "azuremonitor"
      http_correlation_protocol = "invalid"
    }
  }
}

run "unsupported_operation_name_format_is_rejected" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    settings = {
      identifier            = "azuremonitor"
      operation_name_format = "invalid"
    }
  }
}
