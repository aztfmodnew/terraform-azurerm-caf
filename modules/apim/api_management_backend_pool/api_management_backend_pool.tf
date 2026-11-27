resource "azapi_resource" "resource" {
  type      = "Microsoft.ApiManagement/service/backends@${var.settings.api_version}"
  name      = azurecaf_name.resource.result
  parent_id = local.api_management_id

  body = {
    properties = {
      type        = "Pool"
      title       = try(var.settings.title, null)
      description = try(var.settings.description, null)
      pool = merge(
        { services = [for service in local.services : merge(
          {
            id       = service.id
            weight   = service.weight
            priority = service.priority
          },
          service.preferred_carbon_emission == null ? {} : {
            preferredCarbonEmission = service.preferred_carbon_emission
          }
        )] },
        var.settings.session_affinity == null ? {} : {
          sessionAffinity = {
            sessionId = {
              source = "cookie"
              name   = var.settings.session_affinity.cookie_name
            }
          }
        },
        var.settings.failure_response_status_code == null ? {} : {
          failureResponse = {
            statusCode = var.settings.failure_response_status_code
          }
        }
      )
    }
  }
  response_export_values = ["properties"]

  lifecycle {
    precondition {
      condition     = alltrue([for service in local.services : service.id != null && service.id != ""])
      error_message = "Every pool member key must resolve to an APIM backend ID; use an existing key, a direct child ID, or a backend name."
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

resource "azapi_resource_action" "reconnect" {
  count       = try(var.settings.reconnect.enabled, false) ? 1 : 0
  type        = "Microsoft.ApiManagement/service/backends@${var.settings.api_version}"
  resource_id = azapi_resource.resource.id
  action      = "reconnect"
  method      = "POST"
  body        = { properties = { after = try(var.settings.reconnect.after, "PT2M") } }

  dynamic "timeouts" {
    for_each = try(var.settings.action_timeouts, null) == null ? [] : [var.settings.action_timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
