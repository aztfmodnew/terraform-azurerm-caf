locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  location            = can(var.settings.location) ? var.settings.location : var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].location
  resource_group_name = can(var.settings.resource_group_name) || can(var.settings.resource_group.name) ? try(var.settings.resource_group_name, var.settings.resource_group.name) : var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].name
  base_tags           = var.base_tags ? var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].tags : {}
}
