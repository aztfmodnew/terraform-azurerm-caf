module "fabric_capacities" {
  source   = "./modules/analytics/fabric_capacity"
  for_each = try(local.analytics.fabric_capacities, {})

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {}
}

output "fabric_capacities" {
  value = module.fabric_capacities
}
