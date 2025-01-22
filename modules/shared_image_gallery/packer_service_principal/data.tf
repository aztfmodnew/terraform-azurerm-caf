data "azurerm_key_vault_secret" "packer_client_id" {
  name         = format("%s-client-id", var.settings.secret_prefix)
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "packer_secret" {
  name         = format("%s-client-secret", var.settings.secret_prefix)
  key_vault_id = var.key_vault_id
}