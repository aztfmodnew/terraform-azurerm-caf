# CAF naming for Managed Redis
# Note: azurecaf currently has no dedicated resource_type for managed redis; using azurerm_redis_cache resourcetype via azurecaf_name.

resource "azurecaf_name" "managed_redis" {
  name          = var.settings.name
  resource_type = "azurerm_redis_cache"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
