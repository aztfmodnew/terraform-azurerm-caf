# naming convention
resource "azurecaf_name" "adtsb" {
  name          = local.settings.name
  resource_type = "azurerm_digital_twins_endpoint_servicebus"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
# Per options https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/digital_twins_endpoint_servicebus
resource "azurerm_digital_twins_endpoint_servicebus" "adtsb" {
  name                                   = azurecaf_name.adtsb.result
  digital_twins_id                       = local.settings.digital_twins_id
  servicebus_primary_connection_string   = local.settings.servicebus_primary_connection_string
  servicebus_secondary_connection_string = local.settings.servicebus_secondary_connection_string
  dead_letter_storage_secret             = try(local.settings.dead_letter_storage_secret, null)

  lifecycle {
    precondition {
      condition     = try(local.settings.digital_twins_id, null) != null
      error_message = "digital_twins_id must be provided directly or resolved from settings.digital_twins_instance or settings.digital_twins_instance_key."
    }
    precondition {
      condition     = try(local.settings.servicebus_primary_connection_string, null) != null
      error_message = "servicebus_primary_connection_string must be provided directly or resolved from settings.servicebus_topic and settings.topic_auth_rules, or from their *_key forms."
    }
    precondition {
      condition     = try(local.settings.servicebus_secondary_connection_string, null) != null
      error_message = "servicebus_secondary_connection_string must be provided directly or resolved from settings.servicebus_topic and settings.topic_auth_rules, or from their *_key forms."
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
