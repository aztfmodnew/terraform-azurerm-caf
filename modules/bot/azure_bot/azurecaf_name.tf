resource "azurecaf_name" "bot_service" {
  name          = var.settings.name
  resource_type = "azurerm_bot_service_azure_bot"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
