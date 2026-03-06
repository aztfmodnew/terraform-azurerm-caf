locals {
  # Determine use_legacy_slug with precedence:
  # 1. Per-resource override (settings.use_legacy_slug)
  # 2. Global slug_version map (global_settings.slug_version["azurerm_mssql_elasticpool"] == "legacy")
  # 3. Default to false (modern slug behavior)
  use_legacy_slug = try(
    var.settings.use_legacy_slug,
    try(var.global_settings.slug_version["azurerm_mssql_elasticpool"] == "legacy", false),
    false
  )
}

resource "azurecaf_name" "elasticpool" {

  name          = var.settings.name
  resource_type = "azurerm_mssql_elasticpool"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
  use_legacy_slug = local.use_legacy_slug
}

resource "azurerm_mssql_elasticpool" "elasticpool" {

  name                = azurecaf_name.elasticpool.result
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = var.server_name
  max_size_gb         = try(var.settings.max_size_gb, null)
  max_size_bytes      = try(var.settings.max_size_bytes, null)
  zone_redundant      = try(var.settings.zone_redundant, null)
  license_type        = try(var.settings.license_type, null)
  tags                = local.tags

  sku {
    name     = var.settings.sku.name
    tier     = var.settings.sku.tier
    family   = try(var.settings.sku.family, null)
    capacity = var.settings.sku.capacity
  }

  per_database_settings {
    min_capacity = var.settings.per_database_settings.min_capacity
    max_capacity = var.settings.per_database_settings.max_capacity
  }
}