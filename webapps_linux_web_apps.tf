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
    diagnostics                         = local.combined_diagnostics
    managed_identities                  = local.combined_objects_managed_identities
    service_plans                       = local.combined_objects_service_plans
    storage_accounts                    = local.combined_objects_storage_accounts
    vnets                              = local.combined_objects_vnets
    mssql_servers                      = local.combined_objects_mssql_servers
    mssql_databases                    = local.combined_objects_mssql_databases
    application_insights               = local.combined_objects_application_insights
    private_dns                        = local.combined_objects_private_dns
    azuread_applications               = local.combined_objects_azuread_applications
    azuread_service_principal_passwords = local.combined_objects_azuread_service_principal_passwords
  }

  private_endpoints = try(each.value.private_endpoints, {})
}

output "linux_web_apps" {
  value = module.linux_web_apps
}
