resource "azurecaf_name" "project" {
  name          = var.settings.name
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, null)
  random_seed   = try(var.global_settings.random_seed, null)
  resource_type = "azurerm_cognitive_account_ai_foundry_project"
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
