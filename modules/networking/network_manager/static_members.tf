module "static_members" {
  source          = "./static_member"
  for_each        = try(var.settings.static_members, {})
  client_config   = var.client_config
  global_settings = var.global_settings
  settings        = each.value
  remote_objects = {
    vnets          = var.remote_objects.vnets
    network_groups = module.network_groups

  }
}


output "static_members" {
  value = module.static_members
}