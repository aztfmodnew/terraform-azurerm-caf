resource "azurerm_aadb2c_directory" "aadb2c" {
  country_code            = var.settings.country_code
  data_residency_location = var.settings.data_residency_location
  display_name            = var.settings.display_name
  domain_name             = var.settings.domain_name
  resource_group_name     = local.resource_group_name
  sku_name                = var.settings.sku_name
  tags                    = local.tags

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
