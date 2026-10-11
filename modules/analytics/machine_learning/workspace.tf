resource "azurecaf_name" "ws" {
  name          = var.settings.name
  prefixes      = var.global_settings.prefixes
  resource_type = "azurerm_machine_learning_workspace"
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_machine_learning_workspace" "ws" {
  name                            = azurecaf_name.ws.result
  location                        = local.location
  resource_group_name             = local.resource_group_name
  application_insights_id         = var.application_insights_id
  key_vault_id                    = var.keyvault_id
  storage_account_id              = var.storage_account_id
  container_registry_id           = try(coalesce(var.container_registry_id, var.settings.container_registry_id), null)
  sku_name                        = try(var.settings.sku_name, null)
  kind                            = try(var.settings.kind, null)
  image_build_compute_name        = try(var.settings.image_build_compute_name, null)
  description                     = try(var.settings.description, null)
  friendly_name                   = try(var.settings.friendly_name, null)
  high_business_impact            = try(var.settings.high_business_impact, null)
  public_network_access_enabled   = coalesce(try(var.settings.public_network_access_enabled, null), true)
  primary_user_assigned_identity  = try(var.settings.primary_user_assigned_identity, null)
  v1_legacy_mode_enabled          = coalesce(try(var.settings.v1_legacy_mode_enabled, null), false)
  storage_account_access_type     = try(var.settings.storage_account_access_type, null)
  service_side_encryption_enabled = try(var.settings.service_side_encryption_enabled, null)
  tags                            = local.tags

  dynamic "identity" {
    for_each = [1]

    content {
      type         = local.identity_type
      identity_ids = contains(["userassigned", "systemassigned, userassigned"], lower(local.identity_type)) ? local.identity_ids : null
    }
  }

  dynamic "encryption" {
    for_each = try(var.settings.encryption, null) == null ? [] : [var.settings.encryption]

    content {
      key_vault_id              = encryption.value.key_vault_id
      key_id                    = encryption.value.key_id
      user_assigned_identity_id = try(encryption.value.user_assigned_identity_id, null)
    }
  }

  dynamic "managed_network" {
    for_each = try(var.settings.managed_network, null) == null ? [] : [var.settings.managed_network]

    content {
      isolation_mode                = try(managed_network.value.isolation_mode, null)
      provision_on_creation_enabled = try(managed_network.value.provision_on_creation_enabled, null)
    }
  }

  dynamic "feature_store" {
    for_each = try(var.settings.feature_store, null) == null ? [] : [var.settings.feature_store]

    content {
      computer_spark_runtime_version = try(feature_store.value.computer_spark_runtime_version, null)
      offline_connection_name        = try(feature_store.value.offline_connection_name, null)
      online_connection_name         = try(feature_store.value.online_connection_name, null)
    }
  }

  dynamic "serverless_compute" {
    for_each = try(var.settings.serverless_compute, null) == null ? [] : [var.settings.serverless_compute]

    content {
      subnet_id = try(serverless_compute.value.subnet_id, null)
      # AzureRM rejects public_ip_enabled = false when no subnet_id is supplied and
      # public network access is disabled, so the default follows that constraint
      # instead of the provider default of false.
      public_ip_enabled = coalesce(
        try(serverless_compute.value.public_ip_enabled, null),
        try(serverless_compute.value.subnet_id, null) == null && coalesce(try(var.settings.public_network_access_enabled, null), true) == false
      )
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    precondition {
      condition = (
        length(try(local.network_outbound_rules.fqdn, {})) == 0 &&
        length(try(local.network_outbound_rules.private_endpoint, {})) == 0 &&
        length(try(local.network_outbound_rules.service_tag, {})) == 0
      ) || try(var.settings.managed_network, null) != null
      error_message = "Network outbound rules require managed_network to be configured."
    }
  }
}
