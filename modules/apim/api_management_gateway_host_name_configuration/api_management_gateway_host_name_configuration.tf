resource "azurerm_api_management_gateway_host_name_configuration" "resource" {
  name                               = azurecaf_name.resource.result
  api_management_id                  = local.api_management_id
  gateway_name                       = local.gateway_name
  certificate_id                     = local.certificate_id
  host_name                          = var.settings.host_name
  request_client_certificate_enabled = try(var.settings.request_client_certificate_enabled, null)
  http2_enabled                      = try(var.settings.http2_enabled, true)
  tls10_enabled                      = try(var.settings.tls10_enabled, null)
  tls11_enabled                      = try(var.settings.tls11_enabled, null)

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
