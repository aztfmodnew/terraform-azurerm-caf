# AzureCAF has no workspace policy fragment type. Reuse the supported
# service-level fragment type with compatible APIM child naming rules.
resource "azurecaf_name" "resource" {
  name          = var.settings.name
  resource_type = "azurerm_api_management_policy_fragment"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
