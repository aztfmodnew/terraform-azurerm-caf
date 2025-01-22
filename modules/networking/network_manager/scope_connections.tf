module "scope_connections" {
  source          = "./scope_connection"
  for_each        = try(var.settings.scope_connections, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_manager_id = azurerm_network_manager.network_manager.id
  }
}

output "scope_connections" {
  value = module.scope_connections
}