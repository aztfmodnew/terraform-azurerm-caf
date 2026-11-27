locals {
  module_tag = {
    module = basename(abspath(path.module))
  }

  location = coalesce(
    try(var.settings.location, null),
    try(var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].location, null),
    try(var.global_settings.regions[var.global_settings.default_region], null),
    try(values(var.global_settings.regions)[0], null)
  )

  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].name, null),
    try(var.remote_objects.resource_groups[var.client_config.landingzone_key][var.settings.resource_group_key].name, null)
  )

  tags = merge(
    var.base_tags ? try(var.global_settings.tags, {}) : {},
    var.base_tags ? coalesce(
      try(var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].tags, null),
      try(var.remote_objects.resource_groups[var.client_config.landingzone_key][var.settings.resource_group_key].tags, null),
      {}
    ) : {},
    local.module_tag,
    try(var.settings.tags, {})
  )
}
