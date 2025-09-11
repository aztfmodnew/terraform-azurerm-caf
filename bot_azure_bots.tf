module "azure_bots" {
  source   = "./modules/bot/azure_bot"
  for_each = local.bot.azure_bots

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    managed_identities = local.combined_objects_managed_identities
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
    private_dns        = local.combined_objects_private_dns
  }
}

output "azure_bots" {
  value = module.azure_bots
}
