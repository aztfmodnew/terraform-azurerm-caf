mock_provider "azurerm" {}

run "api_diagnostic_configuration" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_diagnostic"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config            = { landingzone_key = "local" }
    base_tags                = {}
    remote_objects           = {}
    api_management_logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/loggers/applicationinsights"
    api_management_name      = "example-apim"
    api_name                 = "example-api"
    resource_group_name      = "example-rg"
    settings = {
      identifier                = "applicationinsights"
      always_log_errors         = true
      http_correlation_protocol = "W3C"
      log_client_ip             = true
      sampling_percentage       = 5
      verbosity                 = "verbose"
      operation_name_format     = "Url"
      backend_request = {
        body_bytes     = 32
        headers_to_log = ["content-type", "accept"]
        data_masking = {
          query_params = [
            { mode = "Mask", value = "token" }
          ]
          headers = [
            { mode = "Mask", value = "authorization" }
          ]
        }
      }
      backend_response = {
        body_bytes     = 64
        headers_to_log = ["content-type"]
        data_masking = {
          query_params = [
            { mode = "Hide", value = "secret" }
          ]
        }
      }
      frontend_request = {
        body_bytes     = 16
        headers_to_log = ["origin"]
        data_masking = {
          headers = [
            { mode = "Mask", value = "cookie" }
          ]
        }
      }
      frontend_response = {
        body_bytes     = 24
        headers_to_log = ["content-length"]
      }
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_api_diagnostic.apim.operation_name_format == "Url"
    error_message = "operation_name_format must be configurable."
  }
  assert {
    condition     = one(azurerm_api_management_api_diagnostic.apim.backend_request).body_bytes == 32
    error_message = "Backend request settings must be passed through."
  }
  assert {
    condition     = one(one(azurerm_api_management_api_diagnostic.apim.backend_request).data_masking).query_params[0].value == "token"
    error_message = "Backend request query parameter masking must be nested under its data_masking block."
  }
  assert {
    condition     = one(one(azurerm_api_management_api_diagnostic.apim.backend_request).data_masking).headers[0].value == "authorization"
    error_message = "Backend request header masking must be nested under its data_masking block."
  }
  assert {
    condition     = one(one(azurerm_api_management_api_diagnostic.apim.backend_response).data_masking).query_params[0].mode == "Hide"
    error_message = "Backend response query masking must be passed through."
  }
  assert {
    condition     = one(one(azurerm_api_management_api_diagnostic.apim.frontend_request).data_masking).headers[0].value == "cookie"
    error_message = "Frontend request header masking must be passed through."
  }
}
