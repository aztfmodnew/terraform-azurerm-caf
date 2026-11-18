locals {
  api_management = try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.api_management.key], null)
  api_management_name = coalesce(
    var.settings.api_management_name,
    try(var.settings.api_management.name, null),
    try(local.api_management.name, null)
  )
  resource_group_name = coalesce(
    var.settings.resource_group_name,
    try(var.settings.resource_group.name, null),
    try(var.remote_objects.resource_groups[coalesce(try(var.settings.resource_group.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.resource_group.key].name, null),
    try(local.api_management.resource_group_name, null)
  )
}
