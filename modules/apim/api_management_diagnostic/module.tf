resource "azurerm_api_management_diagnostic" "apim" {
  identifier               = var.settings.identifier
  api_management_name      = var.api_management_name
  resource_group_name      = var.resource_group_name
  api_management_logger_id = var.api_management_logger_id

  always_log_errors         = try(var.settings.always_log_errors, null)
  http_correlation_protocol = try(var.settings.http_correlation_protocol, null)
  log_client_ip             = try(var.settings.log_client_ip, null)
  sampling_percentage       = try(var.settings.sampling_percentage, null)
  verbosity                 = try(var.settings.verbosity, null)
  operation_name_format     = try(var.settings.operation_name_format, null)

  dynamic "backend_request" {
    for_each = try(var.settings.backend_request, null) == null ? [] : [var.settings.backend_request]

    content {
      body_bytes     = try(backend_request.value.body_bytes, null)
      headers_to_log = try(backend_request.value.headers_to_log, null)

      dynamic "data_masking" {
        for_each = try(backend_request.value.data_masking, null) == null ? [] : [backend_request.value.data_masking]

        content {
          dynamic "query_params" {
            for_each = try(data_masking.value.query_params, [])

            content {
              mode  = query_params.value.mode
              value = query_params.value.value
            }
          }

          dynamic "headers" {
            for_each = try(data_masking.value.headers, [])

            content {
              mode  = headers.value.mode
              value = headers.value.value
            }
          }
        }
      }
    }
  }

  dynamic "backend_response" {
    for_each = try(var.settings.backend_response, null) == null ? [] : [var.settings.backend_response]

    content {
      body_bytes     = try(backend_response.value.body_bytes, null)
      headers_to_log = try(backend_response.value.headers_to_log, null)

      dynamic "data_masking" {
        for_each = try(backend_response.value.data_masking, null) == null ? [] : [backend_response.value.data_masking]

        content {
          dynamic "query_params" {
            for_each = try(data_masking.value.query_params, [])

            content {
              mode  = query_params.value.mode
              value = query_params.value.value
            }
          }

          dynamic "headers" {
            for_each = try(data_masking.value.headers, [])

            content {
              mode  = headers.value.mode
              value = headers.value.value
            }
          }
        }
      }
    }
  }

  dynamic "frontend_request" {
    for_each = try(var.settings.frontend_request, null) == null ? [] : [var.settings.frontend_request]

    content {
      body_bytes     = try(frontend_request.value.body_bytes, null)
      headers_to_log = try(frontend_request.value.headers_to_log, null)

      dynamic "data_masking" {
        for_each = try(frontend_request.value.data_masking, null) == null ? [] : [frontend_request.value.data_masking]

        content {
          dynamic "query_params" {
            for_each = try(data_masking.value.query_params, [])

            content {
              mode  = query_params.value.mode
              value = query_params.value.value
            }
          }

          dynamic "headers" {
            for_each = try(data_masking.value.headers, [])

            content {
              mode  = headers.value.mode
              value = headers.value.value
            }
          }
        }
      }
    }
  }

  dynamic "frontend_response" {
    for_each = try(var.settings.frontend_response, null) == null ? [] : [var.settings.frontend_response]

    content {
      body_bytes     = try(frontend_response.value.body_bytes, null)
      headers_to_log = try(frontend_response.value.headers_to_log, null)

      dynamic "data_masking" {
        for_each = try(frontend_response.value.data_masking, null) == null ? [] : [frontend_response.value.data_masking]

        content {
          dynamic "query_params" {
            for_each = try(data_masking.value.query_params, [])

            content {
              mode  = query_params.value.mode
              value = query_params.value.value
            }
          }

          dynamic "headers" {
            for_each = try(data_masking.value.headers, [])

            content {
              mode  = headers.value.mode
              value = headers.value.value
            }
          }
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
