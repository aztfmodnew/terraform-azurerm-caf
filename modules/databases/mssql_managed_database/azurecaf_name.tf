locals {
  # Determine use_legacy_slug with precedence:
  # 1. Per-resource override (settings.use_legacy_slug)
  # 2. Global slug_version map (global_settings.slug_version["azurerm_mssql_database"] == "legacy")
  # 3. Default to false (modern slug behavior)
  use_legacy_slug = try(
    var.settings.use_legacy_slug,
    try(var.global_settings.slug_version["azurerm_mssql_database"] == "legacy", false),
    false
  )
}

resource "azurecaf_name" "manageddb" {
  name          = var.settings.name
  resource_type = "azurerm_mssql_database"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_legacy_slug = local.use_legacy_slug
}
