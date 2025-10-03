resource "azurerm_fabric_capacity" "fabric_capacity" {
  name                = azurecaf_name.fabric_capacity.result
  location            = local.location
  resource_group_name = local.resource_group.name
  tags                = local.tags

  administration_members = try(var.settings.administration_members, null)

  sku {
    name = local.sku.name
    tier = coalesce(try(local.sku.tier, null), "Fabric")
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    precondition {
      condition     = local.resource_group.name != null && trim(local.resource_group.name) != ""
      error_message = "Fabric Capacity requires a valid target resource group."
    }

    precondition {
      condition     = local.sku.name != null && trim(local.sku.name) != ""
      error_message = "Fabric Capacity requires \"settings.sku.name\" to be specified."
    }
  }
}
