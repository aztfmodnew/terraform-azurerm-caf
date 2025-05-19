locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    try(var.global_settings.tags, {}),
    try(var.resource_group.tags, {}),
    local.module_tag,
    try(var.settings.tags, {})
    ) : merge(
    local.module_tag,
    try(var.settings.tags, {})
  )

  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = var.resource_group.name
}
