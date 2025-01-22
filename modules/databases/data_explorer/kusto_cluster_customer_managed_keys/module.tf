resource "azurerm_kusto_cluster_customer_managed_key" "kusto" {
  cluster_id    = var.settings.cluster_id
  key_vault_id  = var.key_vault_id
  key_name      = var.key_name
  key_version   = var.key_version
  user_identity = try(var.user_identity, null)
}