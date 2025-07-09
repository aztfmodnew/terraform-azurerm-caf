module "linux_web_apps" {
  source   = "./modules/webapps/linux_web_app"
  for_each = local.webapp.linux_web_apps

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    diagnostics        = local.combined_diagnostics
    managed_identities = local.combined_objects_managed_identities
    service_plans      = local.combined_objects_service_plans
    app_service_plans  = local.combined_objects_app_service_plans
  }
}

output "linux_web_apps" {
  value = module.linux_web_apps
}
