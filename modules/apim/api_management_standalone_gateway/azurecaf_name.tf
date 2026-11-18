# resourceDefinition.json has no standalone-gateway entry. The supported APIM
# service rule is a conservative compatible subset (alphanumeric/dash, <=50).
# global_settings.passthrough preserves a pre-validated existing Azure name.
resource "azurecaf_name" "resource" {
  name          = var.settings.name
  resource_type = "azurerm_api_management"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
