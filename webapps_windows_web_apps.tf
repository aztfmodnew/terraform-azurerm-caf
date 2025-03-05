module "windows_web_apps" {
  source   = "./modules/webapps/windows_web_app"
  for_each = local.webapps.windows_web_apps

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    storage_accounts = local.combined_objects_storage_accounts    
  }
}

output "windows_web_apps" {
  value = module.windows_web_apps
}
