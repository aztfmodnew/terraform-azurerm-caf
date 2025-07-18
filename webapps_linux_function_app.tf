# This file is used to create the Linux Function Apps
module "linux_function_apps" {
  source            = "./modules/webapps/linux_function_app"
  depends_on        = [module.service_plans, module.networking]
  for_each          = local.webapp.linux_function_apps
  client_config     = local.client_config
  global_settings   = local.global_settings
  resource_group    = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags         = local.global_settings.inherit_tags
  location          = try(each.value.location, null)
  private_endpoints = try(each.value.private_endpoints, {})
  settings          = each.value

  remote_objects = {
    service_plans        = local.combined_objects_service_plans
    service_plans        = local.combined_objects_service_plans
    combined_objects     = local.dynamic_app_settings_combined_objects
    diagnostics          = local.combined_diagnostics
    keyvaults            = local.combined_objects_keyvaults
    storage_accounts     = local.combined_objects_storage_accounts
    vnets                = local.combined_objects_networking
    virtual_subnets      = local.combined_objects_virtual_subnets
    managed_identities   = local.combined_objects_managed_identities
    private_dns          = local.combined_objects_private_dns
    application_insights = local.combined_objects_application_insights

  }
}

output "linux_function_apps" {
  value       = module.linux_function_apps
  description = "Output of the Linux Function Apps module"
}

