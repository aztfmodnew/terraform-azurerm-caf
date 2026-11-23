locals {
  api_tag_id = coalesce(
    try(var.settings.api_tag_id, null),
    try(var.settings.api_tag.id, null),
    try(var.remote_objects.api_management_api_tag[coalesce(try(var.settings.api_tag.lz_key, null), var.client_config.landingzone_key)][var.settings.api_tag.key].id, null)
  )
}
