resource "azurecaf_name" "windows_web_app_slot" {
  name          = var.settings.name
  resource_type = "general"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
