resource "azurecaf_name" "account" {
  name          = local.final_name
  prefixes      = var.global_settings.prefixes
  resource_type = "azurerm_netapp_account"
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_netapp_account" "account" {
  # Must be unique for the subscription.
  name                = local.final_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags
  lifecycle {
    ignore_changes = [resource_group_name, location, name]
  }

}
