resource "azapi_resource" "linkReferences" {
  for_each  = try(var.settings.link_references, {})
  type      = "Microsoft.Network/networkSecurityPerimeters/linkReferences@2023-08-01-preview"
  name      = each.value.name
  parent_id = azapi_resource.networkSecurityPerimeter.id
}