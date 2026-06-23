locals {
  raw_settings = try(var.settings, {})

  legacy_settings = {
    for key, value in {
      name     = var.name
      tags     = var.tags
      identity = var.identity
      timeouts = var.timeouts
    } : key => value if value != null
  }

  settings = merge(local.raw_settings, local.legacy_settings)

  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = merge(var.base_tags, local.module_tag, try(local.settings.tags, null) == null ? {} : local.settings.tags)

  identity_type_normalized = try(replace(lower(local.settings.identity.type), " ", ""), null)

  identity_uses_user_assigned = local.identity_type_normalized != null ? contains([
    "userassigned",
    "systemassigned,userassigned",
    "userassigned,systemassigned"
  ], local.identity_type_normalized) : false
}