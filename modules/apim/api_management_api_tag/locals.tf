locals {
  api_id = coalesce(
    try(var.settings.api_id, null),
    try(var.settings.api.id, null),
    try(var.remote_objects.api_management_api[coalesce(try(var.settings.api.lz_key, null), var.client_config.landingzone_key)][var.settings.api.key].id, null)
  )
  tag_name = coalesce(
    try(var.settings.name, null),
    try(var.settings.tag.name, null),
    try(reverse(split("/", var.settings.tag.id))[0], null),
    try(var.remote_objects.api_management_tag[coalesce(try(var.settings.tag.lz_key, null), var.client_config.landingzone_key)][var.settings.tag.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management_tag[coalesce(try(var.settings.tag.lz_key, null), var.client_config.landingzone_key)][var.settings.tag.key].id))[0], null)
  )
}
