locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(
    var.base_tags ? var.global_settings.tags : {},
    local.module_tag,
    try(var.settings.tags, null)
  )

  location = coalesce(
    try(var.settings.location, null),
    var.location,
    var.resource_group.location
  )

  resource_group_name = coalesce(
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][try(var.settings.resource_group.key, var.settings.resource_group_key)].name, null)
  )
}
