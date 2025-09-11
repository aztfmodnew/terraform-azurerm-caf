resource "azurecaf_name" "ms_teams_channel" {
  name          = var.settings.name
  resource_type = "azurerm_bot_channel_ms_teams"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
