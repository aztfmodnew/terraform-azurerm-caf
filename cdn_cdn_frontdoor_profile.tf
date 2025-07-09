module "cdn_frontdoor_profiles" {
  source   = "./modules/cdn/cdn_frontdoor_profile"
  for_each = local.cdn.cdn_frontdoor_profiles

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    diagnostics                   = local.combined_diagnostics
    keyvault_certificate_requests = local.combined_objects_keyvault_certificate_requests
    managed_identities            = local.combined_objects_managed_identities
    storage_accounts              = local.combined_objects_storage_accounts
  }
}

output "cdn_frontdoor_profiles" {
  value = module.cdn_frontdoor_profiles
}
