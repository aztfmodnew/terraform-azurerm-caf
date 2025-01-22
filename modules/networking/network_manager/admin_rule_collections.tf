module "admin_rule_collections" {
  source          = "./admin_rule_collection"
  for_each        = try(var.settings.admin_rule_collections, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    network_groups                = module.network_groups
    security_admin_configurations = module.security_admin_configurations
  }
}