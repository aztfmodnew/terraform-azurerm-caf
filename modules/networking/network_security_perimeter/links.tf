resource "azapi_resource" "links" {
  for_each = try(var.settings.links, {})

  type                 = "Microsoft.Network/networkSecurityPerimeters/links@2025-07-01"
  name                 = each.value.name
  parent_id            = azapi_resource.networkSecurityPerimeter.id
  ignore_null_property = true
  depends_on           = [azapi_resource.profiles]

  body = {
    properties = {
      autoApprovedRemotePerimeterResourceId = try(each.value.auto_approved_remote_perimeter_resource_id, null)
      description                           = try(each.value.description, null)
      localInboundProfiles                  = try(each.value.local_inbound_profiles, null)
      remoteInboundProfiles                 = try(each.value.remote_inbound_profiles, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
