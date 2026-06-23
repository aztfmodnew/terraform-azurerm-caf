
# naming convention
resource "azurecaf_name" "adt" {
  name          = local.settings.name
  resource_type = "azurerm_digital_twins_instance"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# Per options https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/digital_twins_instance
resource "azurerm_digital_twins_instance" "adt" {
  name                = azurecaf_name.adt.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  lifecycle {
    precondition {
      condition     = !local.identity_uses_user_assigned || length(local.managed_identities) > 0
      error_message = "When identity.type includes UserAssigned, provide at least one identity_ids, managed_identity_ids, managed_identity_keys, or remote managed identity key."
    }
  }

  dynamic "identity" {
    for_each = try(local.settings.identity, null) == null ? [] : [local.settings.identity]
    content {
      type         = identity.value.type
      identity_ids = local.identity_uses_user_assigned ? local.managed_identities : null
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
