locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  inherited_tags = var.base_tags ? merge(
    try(var.global_settings.tags, {}),
    try(var.resource_group.tags, {}),
    local.module_tag
  ) : local.module_tag

  tags = merge(
    local.inherited_tags,
    try(var.settings.tags, {})
  )

  resource_group = {
    name = coalesce(
      try(var.settings.resource_group.name, null),
      try(var.settings.resource_group_name, null),
      try(var.resource_group.name, null)
    )
    location = coalesce(
      try(var.settings.resource_group.location, null),
      try(var.resource_group.location, null),
      var.location
    )
    tags = try(var.resource_group.tags, null)
  }

  location = coalesce(
    try(var.settings.location, null),
    var.location,
    local.resource_group.location,
    try(var.global_settings.regions[try(var.settings.region, var.global_settings.default_region)], null)
  )

  resource_name_input = coalesce(
    try(var.settings.name, null),
    try(var.settings.key, null),
    format("fabric-%s", var.client_config.landingzone_key)
  )

  sku = merge({
    name = null
    tier = "Fabric"
  }, try(var.settings.sku, {}))
}
