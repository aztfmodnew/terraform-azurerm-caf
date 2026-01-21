resource "azurecaf_name" "experiment" {
  name          = var.settings.name
  resource_type = "azurerm_resource_group"  # No specific CAF type for chaos experiments
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, null)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
