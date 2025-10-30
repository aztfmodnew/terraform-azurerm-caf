module "grafana" {
  source              = "./modules/dashboards/grafana"
  for_each            = local.dashboards.grafana
  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  location            = try(each.value.location, null)
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name
  private_endpoints   = try(each.value.private_endpoints, {})

  remote_objects = {
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
    private_dns        = local.combined_objects_private_dns
    diagnostics        = local.combined_diagnostics
    resource_groups    = local.combined_objects_resource_groups
    managed_identities = local.combined_objects_managed_identities
  }
}

output "grafana" {
  value = module.grafana
}
