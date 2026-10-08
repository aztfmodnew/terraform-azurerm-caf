
resource "azurecaf_name" "appis" {
  name          = var.name
  resource_type = "azurerm_application_insights"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_application_insights" "appinsights" {
  name                                 = azurecaf_name.appis.result
  location                             = var.location
  resource_group_name                  = var.resource_group_name
  application_type                     = var.application_type
  daily_data_cap_in_gb                 = var.daily_data_cap_in_gb
  daily_data_cap_notifications_enabled = var.daily_data_cap_notifications_enabled == null ? (var.daily_data_cap_notifications_disabled == null ? null : !var.daily_data_cap_notifications_disabled) : var.daily_data_cap_notifications_enabled
  retention_in_days                    = var.retention_in_days
  sampling_percentage                  = var.sampling_percentage
  ip_masking_enabled                   = var.ip_masking_enabled == null ? (var.disable_ip_masking == null ? null : !var.disable_ip_masking) : var.ip_masking_enabled
  workspace_id                         = var.workspace_id
  tags                                 = local.tags
}