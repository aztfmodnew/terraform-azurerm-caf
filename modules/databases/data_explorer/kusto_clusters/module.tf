resource "azurecaf_name" "kusto" {
  name          = var.settings.name
  resource_type = "azurerm_kusto_cluster"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# Last review :  AzureRM version 2.77.0
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster
# Note: Virtual Network injection was retired on February 1, 2025. Use private endpoints for secure networking.
# Reference: https://aka.ms/adx.security.vnet.migration

resource "azurerm_kusto_cluster" "kusto" {
  name                = azurecaf_name.kusto.result
  location            = var.location
  resource_group_name = var.resource_group_name
  dynamic "sku" {
    for_each = try(var.settings.sku, null) != null ? [var.settings.sku] : []

    content {
      name     = sku.value.name
      capacity = lookup(sku.value, "capacity", null)
    }
  }
  double_encryption_enabled = try(var.settings.double_encryption_enabled, null)
  dynamic "identity" {
    for_each = try(var.settings.identity, false) == false ? [] : [1]

    content {
      type         = var.settings.identity.type
      identity_ids = local.managed_identities
    }
  }
  disk_encryption_enabled     = try(var.settings.enable_disk_encryption, var.settings.disk_encryption_enabled, null)
  streaming_ingestion_enabled = try(var.settings.enable_streaming_ingest, var.settings.streaming_ingestion_enabled, null)
  purge_enabled               = try(var.settings.enable_purge, var.settings.purge_enabled, null)

  # virtual_network_configuration block removed - Virtual Network injection was retired on February 1, 2025
  # Use private endpoints instead for secure networking
  # Reference: https://aka.ms/adx.security.vnet.migration
  dynamic "language_extension" {
    for_each = try(
      [for extension in var.settings.language_extension : { name = extension.name, image = extension.image }],
      [for extension in var.settings.language_extensions : { name = extension.name, image = extension.image }],
      [{ name = var.settings.language_extensions.name, image = var.settings.language_extensions.image }],
      []
    )

    content {
      name  = language_extension.value.name
      image = language_extension.value.image
    }
  }


  dynamic "optimized_auto_scale" {
    for_each = try(var.settings.optimized_auto_scale, null) != null ? [var.settings.optimized_auto_scale] : []

    content {
      minimum_instances = optimized_auto_scale.value.minimum_instances
      maximum_instances = optimized_auto_scale.value.maximum_instances
    }
  }
  trusted_external_tenants      = try(var.settings.trusted_external_tenants, null)
  zones                         = try(var.settings.zones, null)
  auto_stop_enabled             = try(var.settings.auto_stop_enabled, null)
  public_network_access_enabled = try(var.settings.public_network_access_enabled, null)
  tags                          = local.tags
}
