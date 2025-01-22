module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_kubernetes_cluster.aks.id
  resource_location = azurerm_kubernetes_cluster.aks.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
