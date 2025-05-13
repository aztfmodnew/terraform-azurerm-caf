module "palo_alto_ngfw_vnet_local_rulestacks" {
  source   = "./modules/networking/palo_alto_ngfw_vnet_local_rulestack"
  for_each = local.networking.palo_alto_ngfw_vnet_local_rulestack

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null) # Can be overridden at the module call level
  settings        = each.value

  remote_objects = {
    diagnostics = local.combined_objects_diagnostics # Or specific diagnostic settings if needed
    # managed_identities = local.combined_objects_managed_identities # If NGFW or Rulestack supported them
    # Add other remote objects if the sub-modules or main module require them
  }
}

output "palo_alto_ngfw_vnet_local_rulestacks" {
  value = module.palo_alto_ngfw_vnet_local_rulestacks
}
