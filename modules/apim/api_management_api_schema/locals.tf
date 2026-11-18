locals {
  api_name = coalesce(
    try(var.settings.api_name, null),
    try(var.settings.api.name, null),
    try(reverse(split("/", var.settings.api.id))[0], null),
    try(var.remote_objects.api_management_api[coalesce(try(var.settings.api.lz_key, null), var.client_config.landingzone_key)][var.settings.api.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management_api[coalesce(try(var.settings.api.lz_key, null), var.client_config.landingzone_key)][var.settings.api.key].id))[0], null)
  )
  api_management_name = coalesce(
    try(var.settings.api_management_name, null),
    try(var.settings.api_management.name, null),
    try(reverse(split("/", var.settings.api_management.id))[0], null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].id))[0], null)
  )
  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(reverse(split("/", var.settings.resource_group.id))[0], null),
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)][var.settings.resource_group.key].name, null)
  )
}
