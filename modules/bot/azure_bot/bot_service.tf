resource "azurerm_bot_service_azure_bot" "bot_service" {
  name                = azurecaf_name.bot_service.result
  resource_group_name = local.resource_group_name
  location            = local.location
  microsoft_app_id    = var.settings.microsoft_app_id
  sku                 = var.settings.sku

  # Optional arguments
  developer_app_insights_api_key        = try(var.settings.developer_app_insights_api_key, null)
  developer_app_insights_application_id = try(var.settings.developer_app_insights_application_id, null)
  developer_app_insights_key            = try(var.settings.developer_app_insights_key, null)
  display_name                          = try(var.settings.display_name, null)
  endpoint                              = try(var.settings.endpoint, null)
  icon_url                              = try(var.settings.icon_url, null)
  microsoft_app_msi_id                  = try(var.settings.microsoft_app_msi_id, null)
  microsoft_app_tenant_id               = try(var.settings.microsoft_app_tenant_id, null)
  microsoft_app_type                    = try(var.settings.microsoft_app_type, null)
  local_authentication_enabled          = try(var.settings.local_authentication_enabled, true)
  luis_app_ids                          = try(var.settings.luis_app_ids, null)
  luis_key                              = try(var.settings.luis_key, null)
  public_network_access_enabled         = try(var.settings.public_network_access_enabled, true)
  streaming_endpoint_enabled            = try(var.settings.streaming_endpoint_enabled, false)
  cmk_key_vault_key_url                 = try(var.settings.cmk_key_vault_key_url, null)

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
