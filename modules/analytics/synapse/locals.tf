locals {
  tags = var.base_tags ? merge(
    coalesce(try(var.global_settings.tags, null), {}),
    coalesce(try(var.resource_group.tags, null), {}),
    var.settings.tags
  ) : var.settings.tags

  location = coalesce(
    try(var.settings.location, null),
    var.location,
    try(var.resource_group.location, null)
  )
  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    var.resource_group_name,
    try(var.resource_group.name, null)
  )

  compute_subnet_id = try(coalesce(
    try(var.settings.compute_subnet_id, null),
    try(var.settings.compute_subnet.id, null),
    try(var.vnets[coalesce(
      try(var.settings.compute_subnet.lz_key, null),
      var.client_config.landingzone_key
    )][var.settings.compute_subnet.vnet_key].subnets[var.settings.compute_subnet.key].id, null)
  ), null)
}
