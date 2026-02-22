locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)

  # Resolve filter resource_groups from multiple possible input patterns:
  # 1. resource_group_key list with current landing zone
  # 2. resources_groups map with per-entry keys in current landing zone
  # 3. resources_groups map with per-entry keys and explicit lz_key
  filter_resource_groups = try(
    flatten([for rg_key in var.settings.filter.resource_group_key : var.resource_groups[var.client_config.landingzone_key][rg_key].name]),
    try(
      flatten([for rg, rg_data in var.settings.filter.resources_groups : [for key in rg_data.key : var.resource_groups[var.client_config.landingzone_key][key].name]]),
      try(
        flatten([for rg, rg_data in var.settings.filter.resources_groups : [for key in rg_data.key : var.resource_groups[rg_data.lz_key][key].name]]),
        []
      )
    )
  )
}
