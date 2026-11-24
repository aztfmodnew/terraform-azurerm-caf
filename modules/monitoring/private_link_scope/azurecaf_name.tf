resource "azurecaf_name" "scope" {
  name          = var.settings.name
  resource_type = "azurerm_monitor_private_link_scope"
  prefixes      = var.global_settings.prefixes
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurecaf_name" "scoped_service" {
  for_each = try(var.settings.scoped_services, {})

  name          = each.value.name
  resource_type = "azurerm_monitor_private_link_scoped_service"
  prefixes      = var.global_settings.prefixes
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
