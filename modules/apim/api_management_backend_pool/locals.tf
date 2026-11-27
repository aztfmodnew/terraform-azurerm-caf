locals {
  module_tag = { module = basename(abspath(path.module)) }
  tags       = merge(var.base_tags, local.module_tag)
  apim_lz    = coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)
  rg_lz      = coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)
  apim       = try(var.remote_objects.api_management[local.apim_lz][var.settings.api_management.key], null)
  rg_name = try(coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.api_management.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(var.remote_objects.resource_groups[local.rg_lz][var.settings.resource_group.key].name, null),
    try(local.apim.resource_group_name, null)
  ), null)
  apim_name = try(coalesce(try(var.settings.api_management.name, null), try(local.apim.name, null)), null)
  api_management_id = coalesce(
    try(var.settings.api_management_id, null),
    try(var.settings.api_management.id, null),
    try(local.apim.id, null),
    try(format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ApiManagement/service/%s",
    var.client_config.subscription_id, local.rg_name, local.apim_name), null)
  )

  services = [
    for service in var.settings.services : {
      id = try(coalesce(
        try(service.id, null),
        try(var.remote_objects[service.source][coalesce(service.lz_key, var.client_config.landingzone_key)][service.key].id, null),
        service.name == null ? null : "${local.api_management_id}/backends/${service.name}"
      ), null)
      weight                    = service.weight
      priority                  = service.priority
      preferred_carbon_emission = service.preferred_carbon_emission
    }
  ]
}
