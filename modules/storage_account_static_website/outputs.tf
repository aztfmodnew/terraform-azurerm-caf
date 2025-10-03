output "id" {
  value       = azurerm_storage_account_static_website.static_website.id
  description = "The ID of the storage account static website"
}

output "static_website" {
  value       = azurerm_storage_account_static_website.static_website
  description = "The storage account static website object"
}