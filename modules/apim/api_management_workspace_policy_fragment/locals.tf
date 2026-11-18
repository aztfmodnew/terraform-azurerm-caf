locals {
  api_management_workspace_id = coalesce(
    var.settings.api_management_workspace_id,
    try(var.settings.api_management_workspace.id, null),
    try(var.remote_objects.api_management_workspace[coalesce(try(var.settings.api_management_workspace.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.api_management_workspace.key].id, null)
  )
}
