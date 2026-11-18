resource "azurerm_api_management_gateway_certificate_authority" "resource" {
  api_management_id = local.api_management_id
  certificate_name  = local.certificate_name
  gateway_name      = local.gateway_name
  is_trusted        = try(var.settings.is_trusted, null)

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
