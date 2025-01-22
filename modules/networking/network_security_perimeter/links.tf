resource "azapi_resource" "links" {
  for_each = try(var.settings.links, {})

  type      = "Microsoft.Network/networkSecurityPerimeters/links@2023-08-01-preview"
  name      = each.value.name
  parent_id = azapi_resource.networkSecurityPerimeter.id

  body = {
    properties = {
      autoApprovedRemotePerimeterResourceId = try(each.value.auto_approved_remote_perimeter_resource_id, null)
      description                           = try(each.value.description, null)
      localInboundProfiles                  = try(each.value.local_inbound_profiles, null)
      remoteInboundProfiles                 = try(each.value.remote_inbound_profiles, null)
    }
  }
}
