# Tested with :  AzureRM version 2.61.0
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault

resource "azurecaf_name" "asr_rg_vault" {
  name          = var.settings.name
  resource_type = "azurerm_recovery_services_vault"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_recovery_services_vault" "asr" {
  name                          = azurecaf_name.asr_rg_vault.result
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = "Standard"
  tags                          = merge(local.tags, try(var.settings.tags, null))
  storage_mode_type             = try(var.settings.storage_mode_type, "GeoRedundant")
  public_network_access_enabled = try(var.settings.public_network_access_enabled, null)
  immutability                  = try(var.settings.immutability, null)

  lifecycle {
    precondition {
      condition     = try(var.settings.soft_delete_enabled, true) != false
      error_message = "AzureRM 5.8 no longer supports disabling Recovery Services Vault soft delete. Remove soft_delete_enabled or set it to true."
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }

}
