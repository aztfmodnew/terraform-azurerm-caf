resource "azurecaf_name" "subnet_service_endpoint_storage_policy" {
  name          = var.settings.name
  resource_type = "azurerm_subnet_service_endpoint_storage_policy"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
