resource "azurerm_storage_queue" "queue" {
  name = var.settings.name
  storage_account_id = coalesce(
    try(var.storage_account_id, null),
    try(var.settings.storage_account_id, null)
  )
  metadata = try(var.settings.metadata, null)
}