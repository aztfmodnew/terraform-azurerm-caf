locals {
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_groups.tags, null),
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)


  resource_group = var.resource_groups[
    coalesce(
      try(var.settings.lz_key, null),
      try(var.settings.resource_group.lz_key, null),
      var.client_config.landingzone_key
    )
    ][
    coalesce(
      try(var.settings.resource_group.key, null),
      try(var.settings.resource_group_key, null)
    )
  ]
}