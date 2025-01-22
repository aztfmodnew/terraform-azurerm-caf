locals {

  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null),
    local.module_tag
  ) : merge(try(var.settings.tags, null), local.module_tag)

  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}