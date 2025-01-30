resource "azurecaf_name" "linux_function_app_slot" {
  name          = var.settings.name
  resource_type = "azurerm_function_app"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}