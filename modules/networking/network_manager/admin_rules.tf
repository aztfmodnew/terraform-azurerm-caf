module "admin_rules" {
  source          = "./admin_rule"
  for_each        = try(var.settings.admin_rules, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    admin_rule_collections = module.admin_rule_collections
  }
}