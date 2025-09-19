resource "azurerm_storage_account_static_website" "static_website" {
  storage_account_id = local.storage_account_id
  index_document     = try(var.settings.index_document, "index.html")
  error_404_document = try(var.settings.error_404_document, "404.html")

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}