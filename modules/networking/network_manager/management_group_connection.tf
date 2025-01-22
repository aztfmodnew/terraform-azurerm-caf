module "management_group_connections" {
  source          = "./management_group_connection"
  for_each        = try(var.settings.management_group_connections, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_manager_id = azurerm_network_manager.network_manager.id
    management_groups  = data.azurerm_management_group.management_groups
  }
}


data "azurerm_management_group" "management_groups" {
  for_each = {
    for key, value in try(var.settings.group_connections.management_group, {}) : key => value
  }

  name = lower(each.key) == "root" ? try(var.settings.group_connection.tenant_id) : each.key
}

output "management_group_connections" {
  value = module.management_group_connections
}