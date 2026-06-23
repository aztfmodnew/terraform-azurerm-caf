# naming convention
resource "azurecaf_name" "adteh" {
  name          = local.settings.name
  resource_type = "azurerm_digital_twins_endpoint_eventhub"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
# Per options https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/digital_twins_endpoint_eventhub
resource "azurerm_digital_twins_endpoint_eventhub" "adteh" {
  name                                 = azurecaf_name.adteh.result
  digital_twins_id                     = local.settings.digital_twins_id
  eventhub_primary_connection_string   = local.settings.eventhub_primary_connection_string
  eventhub_secondary_connection_string = local.settings.eventhub_secondary_connection_string
  dead_letter_storage_secret           = try(local.settings.dead_letter_storage_secret, null)

  lifecycle {
    precondition {
      condition     = try(local.settings.digital_twins_id, null) != null
      error_message = "digital_twins_id must be provided directly or resolved from settings.digital_twins_instance or settings.digital_twins_instance_key."
    }
    precondition {
      condition     = try(local.settings.eventhub_primary_connection_string, null) != null
      error_message = "eventhub_primary_connection_string must be provided directly or resolved from settings.event_hub_auth_rules or settings.event_hub_auth_rules_key."
    }
    precondition {
      condition     = try(local.settings.eventhub_secondary_connection_string, null) != null
      error_message = "eventhub_secondary_connection_string must be provided directly or resolved from settings.event_hub_auth_rules or settings.event_hub_auth_rules_key."
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
