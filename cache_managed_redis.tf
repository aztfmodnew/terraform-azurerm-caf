module "managed_redis" {
  source   = "./modules/cache/managed_redis"
  for_each = try(local.cache.managed_redis, {})

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  location = try(
    each.value.location,
    local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  )
  resource_group      = try(each.value.resource_group, {})
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  private_endpoints   = try(each.value.private_endpoints, {})
  remote_objects = {
    diagnostics        = local.combined_diagnostics
    managed_identities = local.combined_objects_managed_identities
    private_dns        = local.combined_objects_private_dns
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
  }
  diagnostic_profiles = try(each.value.diagnostic_profiles, {})
  diagnostics         = local.combined_diagnostics
}

output "managed_redis" {
  value = module.managed_redis

}
