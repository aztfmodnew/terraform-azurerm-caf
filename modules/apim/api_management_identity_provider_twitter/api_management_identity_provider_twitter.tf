resource "azurerm_api_management_identity_provider_twitter" "resource" {
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  api_key             = var.settings.api_key
  api_secret_key      = var.settings.api_secret_key
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
