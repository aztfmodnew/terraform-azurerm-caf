locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = merge(var.base_tags, local.module_tag, try(var.settings.tags, null), { "hidden-link:${var.application_insights_id}" = "Resource" })
}