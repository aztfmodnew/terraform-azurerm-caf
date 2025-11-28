module "route_servers" {
  source   = "./modules/networking/route_server"
  for_each = local.networking.route_servers

  client_config       = local.client_config
  diagnostic_profiles = try(each.value.diagnostic_profiles, {})
  diagnostics         = local.combined_diagnostics
  global_settings     = local.global_settings
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : null
  base_tags           = try(local.global_settings.inherit_tags, false)
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  settings            = each.value

  remote_objects = {
    public_ip_addresses = local.combined_objects_public_ip_addresses
    virtual_networks    = local.combined_objects_vnets
  }
}

output "route_servers" {
  value = module.route_servers
}
