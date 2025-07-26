

module "proximity_placement_groups" {
  source   = "./modules/compute/proximity_placement_group"
  for_each = local.compute.proximity_placement_groups

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  name            = each.value.name
  tags            = try(each.value.tags, null)
  location        = try(local.global_settings.regions[each.value.region], null)
  base_tags       = local.global_settings.inherit_tags
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
}


output "proximity_placement_groups" {
  value = module.proximity_placement_groups

}
