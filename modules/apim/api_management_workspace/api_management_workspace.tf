resource "azurerm_api_management_workspace" "resource" {
  name              = azurecaf_name.resource.result
  api_management_id = local.api_management_id
  display_name      = var.settings.display_name
  description       = try(var.settings.description, null)
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
