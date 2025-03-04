module "ai_services" {
  source   = "./modules/cognitive_services/ai_services"
  for_each = local.cognitive_services.ai_services

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    storage_accounts   = local.combined_objects_storage_accounts
    managed_identities = local.combined_objects_managed_identities
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
  }
}

output "ai_services" {
  value = module.ai_services
}
