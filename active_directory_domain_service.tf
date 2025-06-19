module "active_directory_domain_service" {
  source   = "./modules/identity/active_directory_domain_service"
  for_each = local.identity.active_directory_domain_service

  # to destroy azuread_group at last
  depends_on = [module.azuread_groups, module.azuread_service_principals]

  global_settings     = local.global_settings
  client_config       = local.client_config
  settings            = each.value
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)
  vnets               = try(local.combined_objects_networking, null)
}
output "active_directory_domain_service" {
  value = module.active_directory_domain_service
}


module "active_directory_domain_service_replica_set" {
  source   = "./modules/identity/active_directory_domain_service_replica_set"
  for_each = local.identity.active_directory_domain_service_replica_set

  depends_on = [azurerm_virtual_network_peering.peering]

  settings      = each.value
  client_config = local.client_config
  location      = try(local.global_settings.regions[each.value.region], null)


  remote_objects = {
    vnets                           = try(local.combined_objects_networking, null)
    active_directory_domain_service = try(module.active_directory_domain_service, null)
  }

}
output "active_directory_domain_service_replica_set" {
  value = module.active_directory_domain_service_replica_set
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service_trust
module "active_directory_domain_service_trust" {
  source   = "./modules/identity/active_directory_domain_service_trust"
  for_each = local.identity.active_directory_domain_service_trust

  depends_on = [module.active_directory_domain_service]

  client_config = local.client_config
  settings      = each.value

  remote_objects = {
    active_directory_domain_service = try(module.active_directory_domain_service, null)
  }
}
output "active_directory_domain_service_trust" {
  value = module.active_directory_domain_service_trust
}