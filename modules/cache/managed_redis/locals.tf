locals {
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)

  location            = coalesce(var.location, try(var.resource_group.location, null))
  resource_group_name = coalesce(var.resource_group_name, try(var.resource_group.name, null))
}
