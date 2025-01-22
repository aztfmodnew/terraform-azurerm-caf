module "connectivity_configurations" {
  source          = "./connectivity_configuration"
  for_each        = try(var.settings.connectivity_configurations, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {

    network_managers = azurerm_network_manager.network_manager
    network_groups   = module.network_groups
    vnets            = var.remote_objects.vnets

  }
}


output "connectivity_configurations" {
  value = module.connectivity_configurations
}