module "mi_federated_credentials" {
  source   = "../../security/mi_federated_credentials"
  for_each = try(var.settings.mi_federated_credentials, {})

  client_config       = var.client_config
  settings            = each.value
  managed_identities  = var.managed_identities
  oidc_issuer_url     = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  resource_group_name = coalesce(try(var.resource_groups[try(each.value.managed_identity.resource_group.lz_key, var.client_config.landingzone_key)][try(each.value.managed_identity.resource_group.key, each.value.managed_identity.resource_group_key)].name, null), try(var.resource_group.name, null))
}
