locals {
  location = coalesce(var.location, var.resource_group.location)

  resource_group = {
    name     = var.resource_group.name
    location = var.resource_group.location
  }

  resource_group_name = local.resource_group.name

  tags = var.base_tags ? merge(
    var.resource_group.tags,
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)
}
