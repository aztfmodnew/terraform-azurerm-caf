output "id" {
  description = "The ID of the File Share"
  # map it to the resource manager id to be compatible with RBAC role_mapping
  value = azurerm_storage_share.fs.id
}

output "name" {
  description = "The URL of the File Share"
  value       = azurerm_storage_share.fs.name
}

output "url" {
  description = "The URL of the File Share"
  value       = azurerm_storage_share.fs.url
}

output "file_share_directories" {
  description = "Output of directories in the file share"
  value       = module.file_share_directory
}