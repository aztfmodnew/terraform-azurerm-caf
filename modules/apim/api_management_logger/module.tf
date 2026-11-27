resource "azurecaf_name" "apim" {
  name          = var.settings.name
  resource_type = "azurerm_api_management_logger"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_api_management_logger" "apim" {
  name                = azurecaf_name.apim.result
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  buffered            = try(var.settings.buffered, null)
  description         = try(var.settings.description, null)
  resource_id         = local.resource_id

  dynamic "application_insights" {
    for_each = try(var.settings.application_insights, null) == null ? [] : [var.settings.application_insights]

    content {
      connection_string   = local.application_insights_connection_string
      instrumentation_key = local.application_insights_instrumentation_key
      identity_client_id  = try(application_insights.value.identity_client_id, null)
    }
  }

  dynamic "eventhub" {
    for_each = try(var.settings.eventhub, null) == null ? [] : [var.settings.eventhub]

    content {
      name                             = local.eventhub_name
      connection_string                = local.eventhub_connection_string
      endpoint_uri                     = local.eventhub_endpoint_uri
      user_assigned_identity_client_id = local.eventhub_user_assigned_identity_client_id
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
