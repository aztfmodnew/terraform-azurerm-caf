module "network_groups" {
  source          = "./network_group"
  for_each        = try(var.settings.network_groups, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_manager_id = azurerm_network_manager.network_manager.id
  }
}


output "network_groups" {
  value = module.network_groups
}