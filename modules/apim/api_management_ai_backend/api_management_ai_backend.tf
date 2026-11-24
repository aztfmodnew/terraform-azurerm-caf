resource "azapi_resource" "resource" {
  type      = "Microsoft.ApiManagement/service/backends@${var.settings.api_version}"
  name      = azurecaf_name.resource.result
  parent_id = local.api_management_id

  body = {
    properties = merge(
      {
        type        = "Single"
        protocol    = var.settings.protocol
        url         = local.endpoint_url
        title       = try(var.settings.title, null)
        description = try(var.settings.description, null)
        resourceId  = try(var.settings.resource_id, null)
        tls         = try(var.settings.tls, null)
      },
      try(var.settings.azure_region, null) == null ? {} : {
        azureRegion = var.settings.azure_region
      }
    )
  }

  response_export_values = ["properties"]

  lifecycle {
    precondition {
      condition     = startswith(local.endpoint, "https://")
      error_message = "AI backend endpoints must use HTTPS, including endpoints resolved from remote objects."
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
  body = {
    properties = {
      after = try(var.settings.reconnect.after, "PT2M")
    }
  }

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
