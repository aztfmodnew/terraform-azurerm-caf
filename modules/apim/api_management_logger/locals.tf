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

  eventhub_namespace_reference = try(coalesce(
    try(var.settings.eventhub.event_hub_namespace, null),
    try(var.settings.eventhub.namespace, null)
  ), null)

  eventhub_reference = try(coalesce(
    try(var.settings.eventhub.event_hub, null),
    try(var.settings.eventhub.hub, null)
  ), null)

  eventhub_authorization_rule_reference = try(coalesce(
    try(var.settings.eventhub.event_hub_authorization_rule, null),
    try(var.settings.eventhub.event_hub_namespace_authorization_rule, null),
    try(var.settings.eventhub.authorization_rule, null)
  ), null)

  eventhub_identity_reference = try(coalesce(
    try(var.settings.eventhub.managed_identity, null),
    try(var.settings.eventhub.identity, null)
  ), null)

  eventhub_remote_namespace = try(
    var.remote_objects.event_hub_namespaces[coalesce(
      try(local.eventhub_namespace_reference.lz_key, null),
      var.client_config.landingzone_key
      )][coalesce(
      try(local.eventhub_namespace_reference.key, null),
      try(var.settings.eventhub.event_hub_namespace_key, null)
    )],
    null
  )

  eventhub_remote_hub = try(
    var.remote_objects.event_hubs[coalesce(
      try(local.eventhub_reference.lz_key, null),
      var.client_config.landingzone_key
      )][coalesce(
      try(local.eventhub_reference.key, null),
      try(var.settings.eventhub.event_hub_key, null)
    )],
    null
  )

  eventhub_remote_hub_authorization_rule = try(
    var.remote_objects.event_hub_auth_rules[coalesce(
      try(local.eventhub_authorization_rule_reference.lz_key, null),
      var.client_config.landingzone_key
      )][coalesce(
      try(local.eventhub_authorization_rule_reference.key, null),
      try(var.settings.eventhub.authorization_rule_key, null)
    )],
    null
  )

  eventhub_remote_namespace_authorization_rule = try(
    var.remote_objects.event_hub_namespace_auth_rules[coalesce(
      try(local.eventhub_authorization_rule_reference.lz_key, null),
      var.client_config.landingzone_key
      )][coalesce(
      try(local.eventhub_authorization_rule_reference.key, null),
      try(var.settings.eventhub.authorization_rule_key, null)
    )],
    null
  )

  eventhub_remote_managed_identity = try(
    var.remote_objects.managed_identities[coalesce(
      try(local.eventhub_identity_reference.lz_key, null),
      var.client_config.landingzone_key
      )][coalesce(
      try(local.eventhub_identity_reference.key, null),
      try(var.settings.eventhub.managed_identity_key, null)
    )],
    null
  )

  eventhub_name = try(coalesce(
    try(var.settings.eventhub.name, null),
    try(var.settings.eventhub.event_hub_name, null),
    try(local.eventhub_reference.name, null),
    try(local.eventhub_remote_hub.name, null)
  ), null)

  eventhub_connection_string = try(coalesce(
    try(var.settings.eventhub.connection_string, null),
    try(local.eventhub_authorization_rule_reference.primary_connection_string, null),
    try(local.eventhub_remote_hub_authorization_rule.primary_connection_string, null),
    try(local.eventhub_remote_namespace_authorization_rule.primary_connection_string, null)
  ), null)

  eventhub_namespace_name = try(coalesce(
    try(var.settings.eventhub.event_hub_namespace_name, null),
    try(local.eventhub_namespace_reference.name, null),
    try(local.eventhub_remote_namespace.name, null)
  ), null)

  eventhub_endpoint_uri = try(coalesce(
    local.eventhub_connection_string == null ? try(var.settings.eventhub.endpoint_uri, null) : null,
    local.eventhub_connection_string == null ? try(local.eventhub_namespace_reference.endpoint_uri, null) : null,
    local.eventhub_connection_string == null ? try(local.eventhub_remote_namespace.endpoint_uri, null) : null,
    local.eventhub_connection_string == null && local.eventhub_namespace_name != null ? format("%s%s", local.eventhub_namespace_name, try(var.cloud.servicebusEndpoint, ".servicebus.windows.net")) : null
  ), null)

  eventhub_user_assigned_identity_client_id = try(coalesce(
    local.eventhub_connection_string == null ? try(var.settings.eventhub.user_assigned_identity_client_id, null) : null,
    local.eventhub_connection_string == null ? try(local.eventhub_identity_reference.client_id, null) : null,
    local.eventhub_connection_string == null ? try(local.eventhub_remote_managed_identity.client_id, null) : null
  ), null)

  eventhub_resource_id = try(coalesce(
    try(var.settings.eventhub.resource_id, null),
    try(local.eventhub_reference.id, null),
    try(local.eventhub_remote_hub.id, null),
    try(local.eventhub_namespace_reference.id, null),
    try(local.eventhub_remote_namespace.id, null)
  ), null)

  resource_id = try(coalesce(
    try(var.settings.resource_id, null),
    try(var.remote_objects.application_insights[coalesce(try(var.settings.resource.lz_key, null), var.client_config.landingzone_key)][var.settings.resource.key].id, null),
    try(var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.resource.key].id, null),
    try(var.settings.resource.id, null),
    local.eventhub_resource_id
  ), null)
}
