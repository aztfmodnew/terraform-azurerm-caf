locals {
  raw_settings = try(var.settings, {})

  digital_twins_instance_lz_key = try(local.raw_settings.digital_twins_instance.lz_key, var.client_config.landingzone_key, null)
  digital_twins_instance_key    = try(local.raw_settings.digital_twins_instance.key, local.raw_settings.digital_twins_instance_key, null)
  event_hub_auth_rules_lz_key   = try(local.raw_settings.event_hub_auth_rules.lz_key, var.client_config.landingzone_key, null)
  event_hub_auth_rules_key      = try(local.raw_settings.event_hub_auth_rules.key, local.raw_settings.event_hub_auth_rules_key, null)

  resolved_settings = {
    digital_twins_id = try(compact([
      try(var.digital_twins_id, null),
      try(var.remote_objects.digital_twins_instances[local.digital_twins_instance_lz_key][local.digital_twins_instance_key].id, null),
      try(local.raw_settings.digital_twins_id, null)
    ])[0], null)
    eventhub_primary_connection_string = try(compact([
      try(var.eventhub_primary_connection_string, null),
      try(var.remote_objects.event_hub_auth_rules[local.event_hub_auth_rules_lz_key][local.event_hub_auth_rules_key].primary_connection_string, null),
      try(local.raw_settings.eventhub_primary_connection_string, null)
    ])[0], null)
    eventhub_secondary_connection_string = try(compact([
      try(var.eventhub_secondary_connection_string, null),
      try(var.remote_objects.event_hub_auth_rules[local.event_hub_auth_rules_lz_key][local.event_hub_auth_rules_key].secondary_connection_string, null),
      try(local.raw_settings.eventhub_secondary_connection_string, null)
    ])[0], null)
  }

  legacy_settings = {
    for key, value in {
      name                                 = var.name
      digital_twins_id                     = var.digital_twins_id
      eventhub_primary_connection_string   = var.eventhub_primary_connection_string
      eventhub_secondary_connection_string = var.eventhub_secondary_connection_string
      dead_letter_storage_secret           = var.dead_letter_storage_secret
      timeouts                             = var.timeouts
    } : key => value if value != null
  }

  settings = merge(
    local.raw_settings,
    { for key, value in local.resolved_settings : key => value if value != null },
    local.legacy_settings
  )
}