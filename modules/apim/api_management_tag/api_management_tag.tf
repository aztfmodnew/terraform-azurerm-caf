resource "azurerm_api_management_tag" "resource" {
  name              = azurecaf_name.resource.result
  api_management_id = local.api_management_id
  display_name      = try(var.settings.display_name, null)

  dynamic "timeouts" {
    for_each = var.settings.timeouts == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
