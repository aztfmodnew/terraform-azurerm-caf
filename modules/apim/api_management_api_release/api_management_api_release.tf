resource "azurerm_api_management_api_release" "resource" {
  name   = azurecaf_name.resource.result
  api_id = local.api_id
  notes  = try(var.settings.notes, null)

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
