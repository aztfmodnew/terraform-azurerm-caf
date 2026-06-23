locals {
  raw_settings = try(var.settings, {})

  digital_twins_instance_lz_key = try(local.raw_settings.digital_twins_instance.lz_key, var.client_config.landingzone_key, null)
  digital_twins_instance_key    = try(local.raw_settings.digital_twins_instance.key, local.raw_settings.digital_twins_instance_key, null)
  eventgrid_topic_lz_key        = try(local.raw_settings.eventgrid_topic.lz_key, var.client_config.landingzone_key, null)
  eventgrid_topic_key           = try(local.raw_settings.eventgrid_topic.key, local.raw_settings.eventgrid_topic_key, null)

  resolved_settings = {
    digital_twins_id = try(compact([
      try(var.digital_twins_id, null),
      try(var.remote_objects.digital_twins_instances[local.digital_twins_instance_lz_key][local.digital_twins_instance_key].id, null),
      try(local.raw_settings.digital_twins_id, null)
    ])[0], null)
    eventgrid_topic_endpoint = try(compact([
      try(var.eventgrid_topic_endpoint, null),
      try(var.remote_objects.eventgrid_topics[local.eventgrid_topic_lz_key][local.eventgrid_topic_key].endpoint, null),
      try(local.raw_settings.eventgrid_topic_endpoint, null)
    ])[0], null)
    eventgrid_topic_primary_access_key = try(compact([
      try(var.eventgrid_topic_primary_access_key, null),
      try(var.remote_objects.eventgrid_topics[local.eventgrid_topic_lz_key][local.eventgrid_topic_key].primary_access_key, null),
      try(local.raw_settings.eventgrid_topic_primary_access_key, null)
    ])[0], null)
    eventgrid_topic_secondary_access_key = try(compact([
      try(var.eventgrid_topic_secondary_access_key, null),
      try(var.remote_objects.eventgrid_topics[local.eventgrid_topic_lz_key][local.eventgrid_topic_key].secondary_access_key, null),
      try(local.raw_settings.eventgrid_topic_secondary_access_key, null)
    ])[0], null)
  }

  legacy_settings = {
    for key, value in {
      name                                 = var.name
      digital_twins_id                     = var.digital_twins_id
      eventgrid_topic_endpoint             = var.eventgrid_topic_endpoint
      eventgrid_topic_primary_access_key   = var.eventgrid_topic_primary_access_key
      eventgrid_topic_secondary_access_key = var.eventgrid_topic_secondary_access_key
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