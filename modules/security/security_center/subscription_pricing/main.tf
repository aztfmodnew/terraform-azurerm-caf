# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing

resource "azurerm_security_center_subscription_pricing" "pricing" {
  tier          = var.settings.tier
  subplan       = try(var.settings.subplan, null)
  resource_type = try(var.settings.resource_type, "VirtualMachines")

  dynamic "extension" {
    for_each = try(var.settings.extensions, {})
    content {
      name                            = extension.value.name
      additional_extension_properties = try(extension.value.additional_extension_properties, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, "1h")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "1h")
      delete = try(timeouts.value.delete, "1h")
    }
  }
}
