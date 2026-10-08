locals {
  storage_share_url = try(coalesce(
    try(var.storage_share_url, null),
    try(var.storage_share_id, null)
  ), null)
}

resource "azurerm_storage_share_directory" "share_directory" {
  name              = var.settings.name
  storage_share_url = local.storage_share_url
  metadata          = try(var.settings.metadata, null)
}