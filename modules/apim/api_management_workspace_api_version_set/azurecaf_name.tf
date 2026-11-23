# AzureCAF has no workspace API version set type. Reuse its service-level
# equivalent: same APIM child name character set and 80-character limit.
resource "azurecaf_name" "resource" {
  name          = var.settings.name
  resource_type = "azurerm_api_management_api_version_set"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
