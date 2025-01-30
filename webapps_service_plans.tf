
module "service_plans" {
  source = "./modules/webapps/service_plan"

  for_each        = local.webapp.service_plans
  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    app_service_environments    = local.combined_objects_app_service_environments
    app_service_environments_v3 = local.combined_objects_app_service_environments_v3
  }
}

output "service_plans" {
  value = module.service_plans
}