mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-backend" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
    tags          = {}
  }
  client_config       = { landingzone_key = "local" }
  api_management_name = "example-apim"
  resource_group_name = "example-rg"
}

run "error_reasons_allow_omitted_status_code_ranges" {
  command = plan

  module {
    source = "../modules/apim/api_management_backend"
  }

  variables {
    settings = {
      name     = "example-backend"
      protocol = "http"
      url      = "https://backend.example.com"
      circuit_breaker_rule = {
        name          = "connection-failures"
        trip_duration = "PT1M"
        failure_condition = {
          interval_duration = "PT5M"
          count             = 5
          error_reasons     = ["BackendConnectionFailure"]
        }
      }
    }
  }

  assert {
    condition     = length(one(one(azurerm_api_management_backend.apim.circuit_breaker_rule).failure_condition).status_code_range) == 0
    error_message = "Error reasons alone must not require HTTP status code ranges."
  }

  assert {
    condition     = one(azurerm_api_management_backend.apim.circuit_breaker_rule).accept_retry_after_enabled == false
    error_message = "Omitted Retry-After support must retain its false default."
  }

  assert {
    condition     = output.name == "example-backend"
    error_message = "The generated backend name must be available to dependent modules."
  }
}

run "error_reasons_allow_explicit_null_status_code_ranges" {
  command = plan

  module {
    source = "../modules/apim/api_management_backend"
  }

  variables {
    settings = {
      name     = "example-backend"
      protocol = "http"
      url      = "https://backend.example.com"
      circuit_breaker_rule = {
        name                       = "connection-failures"
        trip_duration              = "PT1M"
        accept_retry_after_enabled = null
        failure_condition = {
          interval_duration = "PT5M"
          percentage        = 50
          error_reasons     = ["BackendConnectionFailure"]
          status_code_range = null
        }
      }
    }
  }

  assert {
    condition     = length(one(one(azurerm_api_management_backend.apim.circuit_breaker_rule).failure_condition).status_code_range) == 0
    error_message = "Explicit-null status code ranges must behave like omission."
  }

  assert {
    condition     = one(one(azurerm_api_management_backend.apim.circuit_breaker_rule).failure_condition).percentage == 50
    error_message = "A percentage threshold must survive typed settings conversion."
  }

  assert {
    condition     = one(azurerm_api_management_backend.apim.circuit_breaker_rule).accept_retry_after_enabled == false
    error_message = "Explicit-null Retry-After support must retain its false default."
  }
}

run "status_code_ranges_allow_omitted_error_reasons" {
  command = plan

  module {
    source = "../modules/apim/api_management_backend"
  }

  variables {
    settings = {
      name     = "example-backend"
      protocol = "http"
      url      = "https://backend.example.com"
      circuit_breaker_rule = {
        name                       = "http-failures"
        trip_duration              = "PT1M"
        accept_retry_after_enabled = false
        failure_condition = {
          interval_duration = "PT5M"
          count             = 5
          status_code_range = [{
            min = 500
            max = 599
          }]
        }
      }
    }
  }

  assert {
    condition     = one(one(one(azurerm_api_management_backend.apim.circuit_breaker_rule).failure_condition).status_code_range).min == 500
    error_message = "Explicit HTTP status ranges must survive typed settings conversion without requiring error reasons."
  }

  assert {
    condition     = one(azurerm_api_management_backend.apim.circuit_breaker_rule).accept_retry_after_enabled == false
    error_message = "An explicit false Retry-After setting must be preserved."
  }
}
