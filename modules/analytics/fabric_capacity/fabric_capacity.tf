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
      condition     = local.resource_group.name != null && trimspace(local.resource_group.name) != ""
      error_message = "Fabric Capacity requires a valid target resource group."
    }

    precondition {
      condition     = local.sku.name != null && trimspace(local.sku.name) != ""
      error_message = "Fabric Capacity requires \"settings.sku.name\" to be specified."
    }

    precondition {
      condition = contains(
        ["F2", "F4", "F8", "F16", "F32", "F64", "F128", "F256", "F512", "F1024", "F2048"],
        local.sku.name
      )
      error_message = "Fabric Capacity SKU name must be one of F2, F4, F8, F16, F32, F64, F128, F256, F512, F1024, or F2048."
    }

    precondition {
      condition     = coalesce(local.sku.tier, "Fabric") == "Fabric"
      error_message = "Fabric Capacity supports only the Fabric SKU tier."
    }
  }
}
