locals {
  resolved_resource_group = try(
    var.remote_objects.resource_groups[coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)][var.settings.resource_group.key],
    null
  )
  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(reverse(split("/", var.settings.resource_group.id))[0], null),
    try(var.resource_group.name, null),
    try(local.resolved_resource_group.name, null)
  )
  location = coalesce(
    try(var.settings.location, null),
    var.location,
    try(var.global_settings.regions[var.settings.region], null),
    try(var.resource_group.location, null),
    try(local.resolved_resource_group.location, null),
    try(var.global_settings.regions[var.global_settings.default_region], null)
  )
  tags = merge(
    var.base_tags ? try(var.global_settings.tags, null) : null,
    var.base_tags ? try(local.resolved_resource_group.tags, null) : null,
    var.base_tags ? try(var.resource_group.tags, null) : null,
    { module = basename(abspath(path.module)) },
    try(var.settings.tags, null)
  )
  backend_subnet_id = try(coalesce(
    try(var.settings.backend_subnet_id, null),
    try(var.settings.subnet.id, null),
    try(var.remote_objects.vnets[coalesce(try(var.settings.subnet.lz_key, null), var.client_config.landingzone_key)][var.settings.subnet.vnet_key].subnets[var.settings.subnet.key].id, null)
  ), null)
}
