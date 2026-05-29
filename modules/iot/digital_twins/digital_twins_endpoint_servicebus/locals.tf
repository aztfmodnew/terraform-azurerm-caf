locals {
  raw_settings = try(var.settings, {})

  digital_twins_instance_lz_key = try(local.raw_settings.digital_twins_instance.lz_key, var.client_config.landingzone_key, null)
  digital_twins_instance_key    = try(local.raw_settings.digital_twins_instance.key, local.raw_settings.digital_twins_instance_key, null)
  servicebus_topic_lz_key       = try(local.raw_settings.servicebus_topic.lz_key, var.client_config.landingzone_key, null)
  servicebus_topic_key          = try(local.raw_settings.servicebus_topic.key, local.raw_settings.servicebus_topic_key, null)
  topic_auth_rules_key          = try(local.raw_settings.topic_auth_rules.key, local.raw_settings.topic_auth_rules_key, null)

  resolved_settings = {
    digital_twins_id = try(compact([
      try(var.digital_twins_id, null),
      try(var.remote_objects.digital_twins_instances[local.digital_twins_instance_lz_key][local.digital_twins_instance_key].id, null),
      try(local.raw_settings.digital_twins_id, null)
    ])[0], null)
    servicebus_primary_connection_string = try(compact([
      try(var.servicebus_primary_connection_string, null),
      try(var.remote_objects.servicebus_topics[local.servicebus_topic_lz_key][local.servicebus_topic_key].topic_auth_rules[local.topic_auth_rules_key].primary_connection_string, null),
      try(local.raw_settings.servicebus_primary_connection_string, null)
    ])[0], null)
    servicebus_secondary_connection_string = try(compact([
      try(var.servicebus_secondary_connection_string, null),
      try(var.remote_objects.servicebus_topics[local.servicebus_topic_lz_key][local.servicebus_topic_key].topic_auth_rules[local.topic_auth_rules_key].secondary_connection_string, null),
      try(local.raw_settings.servicebus_secondary_connection_string, null)
    ])[0], null)
  }

  legacy_settings = {
    for key, value in {
      name                                   = var.name
      digital_twins_id                       = var.digital_twins_id
      servicebus_primary_connection_string   = var.servicebus_primary_connection_string
      servicebus_secondary_connection_string = var.servicebus_secondary_connection_string
      dead_letter_storage_secret             = var.dead_letter_storage_secret
      timeouts                               = var.timeouts
    } : key => value if value != null
  }

  settings = merge(
    local.raw_settings,
    { for key, value in local.resolved_settings : key => value if value != null },
    local.legacy_settings
  )
}