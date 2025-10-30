resource "azurecaf_name" "grafana" {
  name          = var.settings.name
  resource_type = "azurerm_dashboard" # azurecaf uses generic dashboard type for Grafana dashboards
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
