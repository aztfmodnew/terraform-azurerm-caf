module "deployments" {
  source          = "./deployment"
  for_each        = try(var.settings.deployments, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_manager_id            = azurerm_network_manager.network_manager.id
    security_admin_configurations = module.security_admin_configurations
    connectivity_configurations   = module.connectivity_configurations
  }
}


output "deployments" {
  value = module.deployments
}