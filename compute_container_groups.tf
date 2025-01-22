module "container_groups" {
  source     = "./modules/compute/container_group"
  for_each   = local.compute.container_groups
  depends_on = [module.dynamic_keyvault_secrets]


  location                 = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name      = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  base_tags                = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  client_config            = local.client_config
  combined_diagnostics     = local.combined_diagnostics
  diagnostic_profiles      = try(each.value.diagnostic_profiles, {})
  global_settings          = local.global_settings
  settings                 = each.value
  dynamic_keyvault_secrets = try(local.security.dynamic_keyvault_secrets, {})

  remote_objects = {
    # Depurar en algún moment para pasar la logica de la subnet_id a remote_objects, error: The given key does not identify an element in this collection value.
    #subnet_id = can(each.value.network_acls.virtual_network_rules.subnet_key) ? local.combined_objects_networking[try(each.value.network_acls.virtual_network_rules.lz_key, local.client_config.landingzone_key)][each.value.network_acls.virtual_network_rules.vnet_key].subnets[each.value.network_acls.virtual_network_rules.subnet_key].id : null
    #subnet_id           = can(each.value.vnet.subnet_key) ? local.combined_objects_networking[try(each.value.vnet.lz_key, local.client_config.landingzone_key)][each.value.vnet.key].subnets[each.value.vnet.subnet_key].id : null
    vnets           = local.combined_objects_networking
    virtual_subnets = local.combined_objects_virtual_subnets
  }


  combined_resources = {
    keyvaults          = local.combined_objects_keyvaults
    managed_identities = local.combined_objects_managed_identities
    network_profiles   = local.combined_objects_network_profiles
  }
}


module "network_profiles" {
  source   = "./modules/networking/network_profile"
  for_each = local.networking.network_profiles

  base_tags       = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]

  remote_objects = {
    networking      = local.combined_objects_networking
    virtual_subnets = local.combined_objects_virtual_subnets
  }
}

output "container_groups" {
  value = module.container_groups
}

