removed {
  from = azapi_resource.linkReferences

  lifecycle {
    destroy = false
  }
}

data "azapi_resource" "linkReferences" {
  for_each               = try(var.settings.link_references, {})
  type                   = "Microsoft.Network/networkSecurityPerimeters/linkReferences@2025-07-01"
  name                   = each.value.name
  parent_id              = azapi_resource.networkSecurityPerimeter.id
  response_export_values = ["*"]
  depends_on             = [azapi_resource.links]

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      read = timeouts.value.read
    }
  }
}