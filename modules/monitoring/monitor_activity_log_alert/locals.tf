locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags     = merge(var.base_tags, local.module_tag, try(var.settings.tags, null))
  location = coalesce(try(var.settings.location, null), var.location)
}