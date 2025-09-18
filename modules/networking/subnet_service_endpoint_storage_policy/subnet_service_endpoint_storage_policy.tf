resource "azurerm_subnet_service_endpoint_storage_policy" "subnet_service_endpoint_storage_policy" {
  name                = azurecaf_name.subnet_service_endpoint_storage_policy.result
  resource_group_name = local.resource_group_name
  location            = local.location

  # Storage policy definition
  dynamic "definition" {
    for_each = try(var.settings.definitions, {})
    content {
      name              = definition.value.name
      description       = try(definition.value.description, null)
      service           = try(definition.value.service, "Microsoft.Storage")
      service_resources = try(definition.value.service_resources, [])
    }
  }

  tags = merge(local.tags, try(var.settings.tags, null))

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, "30m")
      update = try(timeouts.value.update, "30m")
      read   = try(timeouts.value.read, "5m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
