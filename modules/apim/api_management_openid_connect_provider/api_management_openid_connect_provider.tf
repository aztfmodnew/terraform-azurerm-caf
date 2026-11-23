resource "azurerm_api_management_openid_connect_provider" "resource" {
  name                = azurecaf_name.resource.result
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  display_name        = var.settings.display_name
  client_id           = var.settings.client_id
  client_secret       = var.settings.client_secret
  metadata_endpoint   = var.settings.metadata_endpoint
  description         = try(var.settings.description, null)
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
