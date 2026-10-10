resource "azurerm_api_management_subscription" "apim" {
  api_management_name = var.api_management_name
  display_name        = var.settings.display_name
  resource_group_name = var.resource_group_name
  product_id          = var.product_id
  user_id             = try(var.settings.user_id, null)
  api_id              = try(var.settings.api_id, null)
  primary_key         = try(var.settings.primary_key, null)
  secondary_key       = try(var.settings.secondary_key, null)
  state               = var.settings.state
  subscription_id     = try(var.settings.subscription_id, null)
  allow_tracing       = var.settings.allow_tracing

  lifecycle {
    precondition {
      condition     = var.product_id == null || try(var.settings.api_id, null) == null
      error_message = "Only one of product_id and api_id can be configured for an API Management subscription."
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
