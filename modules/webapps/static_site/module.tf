resource "azurecaf_name" "static_site" {
  name          = var.name
  resource_type = "azurerm_static_site" # Using supported resource type until azurecaf supports azurerm_static_web_app
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_static_web_app" "static_site" {
  name                = azurecaf_name.static_site.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  sku_size = var.sku_size
  sku_tier = var.sku_tier

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [1]

    content {
      type         = var.settings.identity.type
      identity_ids = lower(var.identity.type) == "userassigned" ? local.managed_identities : null
    }
  }
}
