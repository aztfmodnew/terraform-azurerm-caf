mock_provider "azurerm" {}

run "diagnostic_with_data_masking_and_timeouts" {
  command = plan

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    global_settings          = {}
    client_config            = { landingzone_key = "local" }
    remote_objects           = {}
    base_tags                = {}
    api_management_name      = "example-apim"
    resource_group_name      = "example-rg"
    api_management_logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/loggers/ai"
    settings = {
      identifier                = "applicationinsights"
      always_log_errors         = true
      http_correlation_protocol = "W3C"
      log_client_ip             = true
      sampling_percentage       = 25.5
      verbosity                 = "verbose"
      operation_name_format     = "Url"
      backend_request = {
        body_bytes     = 8192
        headers_to_log = ["content-type", "authorization"]
        data_masking = {
          query_params = [{ mode = "Mask", value = "token" }]
          headers      = [{ mode = "Mask", value = "authorization" }]
        }
      }
      backend_response = {
        body_bytes   = 128
        data_masking = { query_params = [{ mode = "Hide", value = "session" }] }
      }
      frontend_request = {
        headers_to_log = ["content-type"]
        data_masking   = { headers = [{ mode = "Mask", value = "cookie" }] }
      }
      frontend_response = {
        body_bytes = 64
      }
      timeouts = {
        create = "45m"
        read   = "8m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_diagnostic.apim.identifier == "applicationinsights" &&
      azurerm_api_management_diagnostic.apim.always_log_errors &&
      azurerm_api_management_diagnostic.apim.http_correlation_protocol == "W3C" &&
      azurerm_api_management_diagnostic.apim.sampling_percentage == 25.5 &&
      azurerm_api_management_diagnostic.apim.operation_name_format == "Url" &&
      azurerm_api_management_diagnostic.apim.backend_request[0].body_bytes == 8192 &&
      azurerm_api_management_diagnostic.apim.backend_request[0].data_masking[0].query_params[0].mode == "Mask" &&
      azurerm_api_management_diagnostic.apim.backend_request[0].data_masking[0].headers[0].value == "authorization" &&
      azurerm_api_management_diagnostic.apim.backend_response[0].data_masking[0].query_params[0].mode == "Hide" &&
      azurerm_api_management_diagnostic.apim.frontend_request[0].data_masking[0].headers[0].mode == "Mask" &&
      azurerm_api_management_diagnostic.apim.frontend_response[0].body_bytes == 64 &&
      azurerm_api_management_diagnostic.apim.timeouts.update == "45m"
    )
    error_message = "The diagnostic must pass through all logging directions, nested masking options, and timeouts."
  }
}

run "diagnostic_supports_azure_monitor_identifier" {
  command = plan

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    global_settings          = {}
    client_config            = { landingzone_key = "local" }
    remote_objects           = {}
    base_tags                = {}
    api_management_name      = "example-apim"
    resource_group_name      = "example-rg"
    api_management_logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/loggers/monitor"
    settings = {
      identifier = "azuremonitor"
    }
  }

  assert {
    condition     = azurerm_api_management_diagnostic.apim.identifier == "azuremonitor"
    error_message = "Azure Monitor must be accepted as a supported diagnostic identifier."
  }
}

run "diagnostic_rejects_body_bytes_above_provider_limit" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_diagnostic"
  }

  variables {
    global_settings          = {}
    client_config            = { landingzone_key = "local" }
    remote_objects           = {}
    base_tags                = {}
    api_management_name      = "example-apim"
    resource_group_name      = "example-rg"
    api_management_logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/loggers/ai"
    settings = {
      identifier       = "applicationinsights"
      frontend_request = { body_bytes = 8193 }
    }
  }
}
