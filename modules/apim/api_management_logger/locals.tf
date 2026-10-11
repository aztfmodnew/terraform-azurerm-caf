locals {
  application_insights_direct_connection_string   = try(var.settings.application_insights.connection_string, null)
  application_insights_direct_instrumentation_key = try(var.settings.application_insights.instrumentation_key, null)
  application_insights_identity_client_id         = try(var.settings.application_insights.identity_client_id, null)

  application_insights_remote_connection_string = try(coalesce(
    try(var.remote_objects.application_insights[coalesce(try(var.settings.application_insights.lz_key, null), var.client_config.landingzone_key)][var.settings.application_insights.key].connection_string, null),
    try(var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insights.key].connection_string, null)
  ), null)

  application_insights_remote_instrumentation_key = try(coalesce(
    try(var.remote_objects.application_insights[coalesce(try(var.settings.application_insights.lz_key, null), var.client_config.landingzone_key)][var.settings.application_insights.key].instrumentation_key, null),
    try(var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insights.key].instrumentation_key, null)
  ), null)

  application_insights_connection_string = try(coalesce(
    local.application_insights_direct_connection_string,
    local.application_insights_direct_instrumentation_key == null && (
      local.application_insights_identity_client_id != null ||
      local.application_insights_remote_instrumentation_key == null
    ) ? local.application_insights_remote_connection_string : null
  ), null)

  application_insights_instrumentation_key = try(coalesce(
    local.application_insights_direct_instrumentation_key,
    local.application_insights_direct_connection_string == null &&
    local.application_insights_identity_client_id == null ? local.application_insights_remote_instrumentation_key : null
  ), null)

  resource_id = try(coalesce(
    try(var.settings.resource_id, null),
    try(var.remote_objects.application_insights[coalesce(try(var.settings.resource.lz_key, null), var.client_config.landingzone_key)][var.settings.resource.key].id, null),
    try(var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.resource.key].id, null),
    try(var.settings.resource.id, null)
  ), null)
}
