# This file is used to create the Linux Function Apps
module "linux_function_apps" {
  source   = "./modules/webapps/linux_function_app"
  for_each = local.webapp.linux_function_apps
  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    app_service_plans = local.combined_objects_app_service_plans
    combined_objects  = local.dynamic_app_settings_combined_objects
    diagnostics       = local.combined_diagnostics
    keyvaults         = local.combined_objects_keyvaults
    storage_accounts  = local.combined_objects_storage_accounts
    vnets             = local.combined_objects_networking
  }
}

output "linux_function_apps" {
  value = module.linux_function_apps
}

