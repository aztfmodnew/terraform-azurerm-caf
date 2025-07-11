resource "azurecaf_name" "windows_function_app" {
  name          = var.settings.name
  resource_type = "azurerm_function_app"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
