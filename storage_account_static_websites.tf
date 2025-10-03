module "storage_account_static_websites" {
  source   = "./modules/storage_account_static_website"
  for_each = local.storage.storage_account_static_websites

  global_settings = local.global_settings
  client_config   = local.client_config
  location        = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = try(local.global_settings.inherit_tags, false)
  settings        = each.value

  remote_objects = {
    storage_accounts = local.combined_objects_storage_accounts
  }
}

# Backward compatibility: automatically create static websites for storage accounts with static_website block
module "storage_account_static_websites_compat" {
  source = "./modules/storage_account_static_website"
  for_each = {
    for k, v in var.storage_accounts : k => v
    if can(v.static_website)
  }

  global_settings = local.global_settings
  client_config   = local.client_config
  location        = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = try(local.global_settings.inherit_tags, false)

  # Convert old static_website structure to new format
  settings = merge(
    {
      storage_account = {
        key = each.key
      }
    },
    each.value.static_website
  )

  remote_objects = {
    storage_accounts = local.combined_objects_storage_accounts
  }

  depends_on = [module.storage_accounts]
}

output "storage_account_static_websites" {
  value = merge(
    module.storage_account_static_websites,
    module.storage_account_static_websites_compat
  )
}