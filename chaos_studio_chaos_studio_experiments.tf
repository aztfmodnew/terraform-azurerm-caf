module "chaos_studio_experiments" {
  source   = "./modules/chaos_studio/chaos_studio_experiment"
  for_each = local.chaos_studio.chaos_studio_experiments

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    resource_groups           = local.combined_objects_resource_groups
    chaos_studio_targets      = local.combined_objects_chaos_studio_targets
    chaos_studio_capabilities = local.combined_objects_chaos_studio_capabilities
    managed_identities        = local.combined_objects_managed_identities
  }
}

output "chaos_studio_experiments" {
  value = module.chaos_studio_experiments
}
