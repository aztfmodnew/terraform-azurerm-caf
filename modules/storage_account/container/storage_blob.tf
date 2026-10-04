module "blob" {
  source     = "../blob"
  depends_on = [azurerm_storage_container.stg]
  for_each   = try(var.settings.storage_blobs, {})

  storage_container_id = azurerm_storage_container.stg.id
  settings             = each.value
  var_folder_path      = var.var_folder_path
}