resource "azurecaf_name" "cost_anomaly_alert" {
  name          = var.settings.name
  resource_type = "azurerm_cost_anomaly_alert"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  use_slug      = try(var.global_settings.use_slug, true)
  clean_input   = true
  separator     = try(var.global_settings.separator, "-")
}
