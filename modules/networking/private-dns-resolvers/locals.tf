locals {
  tags = var.inherit_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null)
  ) : null
  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}

