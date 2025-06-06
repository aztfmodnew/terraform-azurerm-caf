locals {
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}

