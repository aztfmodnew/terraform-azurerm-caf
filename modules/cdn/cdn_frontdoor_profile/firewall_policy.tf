module "firewall_policies" {
  source   = "./firewall_policy"
  for_each = try(var.settings.firewall_policies, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = var.remote_objects
}
