locals {
  base_tags           = try(var.global_settings.inherit_tags, false) ? var.resource_group.tags : {}
  location            = lookup(var.settings, "region", null) == null ? var.resource_group.location : var.global_settings.regions[var.settings.region]
  resource_group_name = var.resource_group.name
}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  # tags = merge(var.base_tags, local.module_tag, var.tags)
  tags = var.tags # temporal use until tag uppercase fixed
}
