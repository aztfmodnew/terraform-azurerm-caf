module "network_security_perimeters" {
  source   = "./modules/networking/network_security_perimeter"
  for_each = local.networking.network_security_perimeters

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value



  remote_objects = {
    storage_accounts = local.combined_objects_storage_accounts
    keyvaults        = local.combined_objects_keyvaults
    event_hubs       = local.combined_objects_event_hubs
    cosmos_dbs       = local.combined_objects_cosmos_dbs
    mssql_servers    = local.combined_objects_mssql_servers
    diagnostics      = local.combined_diagnostics
  }
}

output "network_security_perimeters" {
  value = module.network_security_perimeters
}
