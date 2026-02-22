module "mi_federated_credentials" {
  source   = "../../security/mi_federated_credentials"
  for_each = try(var.settings.mi_federated_credentials, {})

  client_config       = var.client_config
  settings            = each.value
  managed_identities  = var.managed_identities
  oidc_issuer_url     = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  resource_group_name = var.managed_identities[try(each.value.managed_identity.lz_key, var.client_config.landingzone_key)][each.value.managed_identity.key].resource_group_name
}
