# naming convention
resource "azurecaf_name" "adteg" {
  name          = local.settings.name
  resource_type = "azurerm_digital_twins_endpoint_eventgrid"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
# Per options https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/digital_twins_endpoint_eventgrid
resource "azurerm_digital_twins_endpoint_eventgrid" "adteg" {
  name                                 = azurecaf_name.adteg.result
  digital_twins_id                     = local.settings.digital_twins_id
  eventgrid_topic_endpoint             = local.settings.eventgrid_topic_endpoint
  eventgrid_topic_primary_access_key   = local.settings.eventgrid_topic_primary_access_key
  eventgrid_topic_secondary_access_key = local.settings.eventgrid_topic_secondary_access_key
  dead_letter_storage_secret           = try(local.settings.dead_letter_storage_secret, null)

  lifecycle {
    precondition {
      condition     = try(local.settings.digital_twins_id, null) != null
      error_message = "digital_twins_id must be provided directly or resolved from settings.digital_twins_instance or settings.digital_twins_instance_key."
    }
    precondition {
      condition     = try(local.settings.eventgrid_topic_endpoint, null) != null
      error_message = "eventgrid_topic_endpoint must be provided directly or resolved from settings.eventgrid_topic or settings.eventgrid_topic_key."
    }
    precondition {
      condition     = try(local.settings.eventgrid_topic_primary_access_key, null) != null
      error_message = "eventgrid_topic_primary_access_key must be provided directly or resolved from settings.eventgrid_topic or settings.eventgrid_topic_key."
    }
    precondition {
      condition     = try(local.settings.eventgrid_topic_secondary_access_key, null) != null
      error_message = "eventgrid_topic_secondary_access_key must be provided directly or resolved from settings.eventgrid_topic or settings.eventgrid_topic_key."
    }
  }

  dynamic "timeouts" {
    for_each = try(local.settings.timeouts, null) == null ? [] : [local.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
