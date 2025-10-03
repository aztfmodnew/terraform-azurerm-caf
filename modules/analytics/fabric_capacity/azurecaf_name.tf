resource "azurecaf_name" "fabric_capacity" {
  name          = local.resource_name_input
  resource_type = "azurerm_fabric_capacity"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  use_slug      = try(var.global_settings.use_slug, true)
  clean_input   = true
  separator     = try(var.global_settings.separator, "-")
}
