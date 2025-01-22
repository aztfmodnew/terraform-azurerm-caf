## getting SP details from for AKV secrets in case provided
data "azurerm_key_vault_secret" "id" {
  count        = can(var.settings.service_principal.client_id) ? 0 : 1
  name         = format("%s-client-id", var.settings.service_principal.keyvault.secret_prefix)
  key_vault_id = var.combined_resources.keyvaults[try(var.settings.service_principal.keyvault.lz_key, var.client_config.landingzone_key)][var.settings.service_principal.keyvault.key].id
}

data "azurerm_key_vault_secret" "password" {
  count        = can(var.settings.service_principal.client_secret) ? 0 : 1
  name         = format("%s-client-secret", var.settings.service_principal.keyvault.secret_prefix)
  key_vault_id = var.combined_resources.keyvaults[try(var.settings.service_principal.keyvault.lz_key, var.client_config.landingzone_key)][var.settings.service_principal.keyvault.key].id
}

## direct pull secret with secret_id literals
data "azurerm_key_vault_secret" "pull_secret" {
  count        = can(var.settings.cluster_profile.pull_secret.secret_id) ? 1 : 0
  name         = var.settings.cluster_profile.pull_secret.secret_name
  key_vault_id = var.settings.cluster_profile.pull_secret.secret_id
}