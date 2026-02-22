# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing

resource "azurerm_security_center_subscription_pricing" "pricing" {
  tier          = var.tier
  subplan       = try(var.subplan, null)
  resource_type = var.resource_type

  dynamic "extension" {
    for_each = coalesce(var.extensions, {})
    content {
      name                            = extension.value.name
      additional_extension_properties = try(extension.value.additional_extension_properties, null)
    }
  }
}
