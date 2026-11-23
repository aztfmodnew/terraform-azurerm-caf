resource "azurerm_api_management_standalone_gateway" "resource" {
  name                 = azurecaf_name.resource.result
  resource_group_name  = local.resource_group_name
  location             = local.location
  backend_subnet_id    = local.backend_subnet_id
  virtual_network_type = try(var.settings.virtual_network_type, null)
  tags                 = local.tags

  dynamic "sku" {
    for_each = [var.settings.sku]
    content {
      name     = sku.value.name
      capacity = try(sku.value.capacity, 1)
    }
  }

  dynamic "timeouts" {
    for_each = var.settings.timeouts == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
