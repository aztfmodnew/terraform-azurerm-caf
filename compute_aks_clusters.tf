module "aks_clusters" {
  source     = "./modules/compute/aks"
  depends_on = [null_resource.register_feature_preview, module.networking, module.routes, module.azurerm_firewall_policies, module.application_gateways, module.application_gateway_platforms, module.application_gateway_applications]
  for_each   = local.compute.aks_clusters

  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value

  admin_group_object_ids = try(each.value.admin_groups.azuread_group_keys, null) == null ? null : try(
    each.value.admin_groups.ids,
    [
      for group_key in try(each.value.admin_groups.azuread_group_keys, {}) :
      coalesce(
        try(local.combined_objects_azuread_groups[each.value.admin_groups.lz_key][group_key].id, null),
        try(local.combined_objects_azuread_groups[local.client_config.landingzone_key][group_key].id, null)
      )
    ]
  )

  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)

  remote_objects = {
    #subnet_id           = can(each.value.vnet.subnet_key) ? local.combined_objects_networking[try(each.value.vnet.lz_key, local.client_config.landingzone_key)][each.value.vnet.key].subnets[each.value.vnet.subnet_key].id : null
    private_dns_zone_id    = can(each.value.settings.private_dns_zone.key) ? local.combined_objects_private_dns[try(each.value.settings.private_dns_zone.lz_key, local.client_config.landingzone_key)][each.value.settings.private_dns_zone.key].id : null
    application_gateway_id = can(each.value.settings.ingress_application_gateway.key) ? local.combined_objects_application_gateway_platforms[try(each.value.settings.ingress_application_gateway.lz_key, local.client_config.landingzone_key)][each.value.settings.ingress_application_gateway.key] : null
    pod_subnet_id          = can(each.value.settings.default_node_pool.pod_subnet_key) ? local.combined_objects_networking[try(each.value.settings.lz_key, var.client_config.landingzone_key)][each.value.settings.vnet_key].subnets[try(each.value.settings.default_node_pool.pod_subnet_key, each.value.settings.default_node_pool.pod_subnet.key)].id : null
    vnet_subnet_id         = can(each.value.settings.default_node_pool.subnet_key) ? local.combined_objects_networking[try(each.value.settings.vnet.lz_key, each.value.settings.lz_key, var.client_config.landingzone_key)][try(each.value.settings.vnet.key, each.value.settings.vnet_key)].subnets[try(each.value.settings.default_node_pool.subnet_key, each.value.settings.default_node_pool.subnet.key)].id : null
    diagnostics            = local.combined_diagnostics
    managed_identities     = local.combined_objects_managed_identities
    vnets                  = local.combined_objects_networking
  }
}


output "aks_clusters" {
  value = module.aks_clusters
}