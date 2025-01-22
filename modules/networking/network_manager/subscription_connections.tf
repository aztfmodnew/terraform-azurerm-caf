module "subscription_connections" {
  source          = "./subscription_connection"
  for_each        = try(var.settings.subscription_connections, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_manager_id = azurerm_network_manager.network_manager.id
  }
}