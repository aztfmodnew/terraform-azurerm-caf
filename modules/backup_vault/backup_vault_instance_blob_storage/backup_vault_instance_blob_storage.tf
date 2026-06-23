resource "azurerm_data_protection_backup_instance_blob_storage" "backup_vault_instance" {
  name               = var.settings.instance_name
  vault_id           = var.vault_id
  location           = var.location
  storage_account_id = var.storage_account_id
  backup_policy_id   = var.backup_policy_id

  # Required for VaultStore: list of containers to protect. 
  # If omitted Azure returns UserErrorInvalidRequestParameter (BackupDatasourceParameters cannot be null).
  storage_account_container_names = lookup(var.settings, "storage_account_container_names", null)
}
