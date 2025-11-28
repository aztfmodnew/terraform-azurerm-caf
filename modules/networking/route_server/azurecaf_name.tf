resource "azurecaf_name" "route_server" {
  name          = try(var.settings.name, null)
  resource_type = "azurerm_route_server"
  prefixes      = try(var.global_settings.prefixes, null)
  random_length = try(var.global_settings.random_length, null)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, null)
  use_slug      = try(var.global_settings.use_slug, null)
}
