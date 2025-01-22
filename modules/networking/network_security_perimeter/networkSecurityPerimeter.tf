resource "azapi_resource" "networkSecurityPerimeter" {
  type = "Microsoft.Network/networkSecurityPerimeters@2023-08-01-preview"
  name = var.settings.name
  #name    = azurecaf_name.nsp.result
  location = coalesce(var.settings.location, local.location)
  body = {
    properties = {}
  }
  parent_id = var.resource_group.id
  tags      = merge(local.tags, try(var.settings.tags, null))
}