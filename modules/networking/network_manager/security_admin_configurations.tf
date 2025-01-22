module "security_admin_configurations" {
  source          = "./security_admin_configuration"
  for_each        = try(var.settings.security_admin_configurations, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_manager_id = azurerm_network_manager.network_manager.id
  }
}