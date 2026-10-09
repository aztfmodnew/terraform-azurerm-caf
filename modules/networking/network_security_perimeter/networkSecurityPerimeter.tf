resource "azapi_resource" "networkSecurityPerimeter" {
  type = "Microsoft.Network/networkSecurityPerimeters@2025-07-01"
  name = var.settings.name
  #name    = azurecaf_name.nsp.result
  location = coalesce(try(var.settings.location, null), local.location)
  body = {
    properties = {}
  }
  parent_id = var.resource_group.id
  tags      = merge(local.tags, try(var.settings.tags, null))

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}