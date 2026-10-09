resource "azurecaf_name" "wp" {
  name          = var.settings.name
  resource_type = coalesce(try(var.settings.azurecaf_resource_type, null), "azurerm_databricks_workspace")
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_databricks_workspace" "ws" {
  name                                                = azurecaf_name.wp.result
  resource_group_name                                 = local.resource_group_name
  location                                            = local.location
  sku                                                 = coalesce(try(var.settings.sku, null), "standard")
  managed_resource_group_name                         = try(var.settings.managed_resource_group_name, null)
  load_balancer_backend_address_pool_id               = try(var.settings.load_balancer_backend_address_pool_id, null)
  managed_services_cmk_key_vault_id                   = try(var.settings.managed_services_cmk_key_vault_id, null)
  managed_services_cmk_key_vault_key_id               = local.managed_services_cmk_key_vault_key_id
  managed_disk_cmk_key_vault_id                       = try(var.settings.managed_disk_cmk_key_vault_id, null)
  managed_disk_cmk_key_vault_key_id                   = local.managed_disk_cmk_key_vault_key_id
  managed_disk_cmk_rotation_to_latest_version_enabled = try(var.settings.managed_disk_cmk_rotation_to_latest_version_enabled, null)
  customer_managed_key_enabled                        = coalesce(try(var.settings.customer_managed_key_enabled, null), false)
  infrastructure_encryption_enabled                   = coalesce(try(var.settings.infrastructure_encryption_enabled, null), false)
  public_network_access_enabled                       = coalesce(try(var.settings.public_network_access_enabled, null), true)
  default_storage_firewall_enabled                    = try(var.settings.default_storage_firewall_enabled, null)
  access_connector_id                                 = local.access_connector_id
  network_security_group_rules_required               = try(var.settings.network_security_group_rules_required, null)
  tags                                                = local.tags

  dynamic "custom_parameters" {
    for_each = try(var.settings.custom_parameters, null) == null ? [] : [var.settings.custom_parameters]

    content {
      machine_learning_workspace_id = local.machine_learning_workspace_id
      nat_gateway_name              = try(custom_parameters.value.nat_gateway_name, null)
      no_public_ip                  = coalesce(try(custom_parameters.value.no_public_ip, null), false)
      public_ip_name                = try(custom_parameters.value.public_ip_name, null)
      public_subnet_name = try(coalesce(
        try(custom_parameters.value.public_subnet_name, null),
        try(
          var.vnets[
            local.databricks_network_lz_key
          ][custom_parameters.value.vnet_key].subnets[custom_parameters.value.public_subnet_key].name,
          null
        )
      ), null)
      public_subnet_network_security_group_association_id = try(coalesce(
        try(custom_parameters.value.public_subnet_network_security_group_association_id, null),
        try(
          var.vnets[
            local.databricks_network_lz_key
          ][custom_parameters.value.vnet_key].subnets[custom_parameters.value.public_subnet_key].id,
          null
        )
      ), null)
      private_subnet_name = try(coalesce(
        try(custom_parameters.value.private_subnet_name, null),
        try(
          var.vnets[
            local.databricks_network_lz_key
          ][custom_parameters.value.vnet_key].subnets[custom_parameters.value.private_subnet_key].name,
          null
        )
      ), null)
      private_subnet_network_security_group_association_id = try(coalesce(
        try(custom_parameters.value.private_subnet_network_security_group_association_id, null),
        try(
          var.vnets[
            local.databricks_network_lz_key
          ][custom_parameters.value.vnet_key].subnets[custom_parameters.value.private_subnet_key].id,
          null
        )
      ), null)
      storage_account_name     = try(custom_parameters.value.storage_account_name, null)
      storage_account_sku_name = try(custom_parameters.value.storage_account_sku_name, null)
      virtual_network_id = try(coalesce(
        try(custom_parameters.value.virtual_network_id, null),
        try(
          var.vnets[
            local.databricks_network_lz_key
          ][custom_parameters.value.vnet_key].id,
          null
        )
      ), null)
      vnet_address_prefix = try(custom_parameters.value.vnet_address_prefix, null)
    }
  }

  dynamic "enhanced_security_compliance" {
    for_each = try(var.settings.enhanced_security_compliance, null) == null ? [] : [var.settings.enhanced_security_compliance]

    content {
      automatic_cluster_update_enabled      = try(enhanced_security_compliance.value.automatic_cluster_update_enabled, null)
      compliance_security_profile_enabled   = try(enhanced_security_compliance.value.compliance_security_profile_enabled, null)
      compliance_security_profile_standards = try(enhanced_security_compliance.value.compliance_security_profile_standards, null)
      enhanced_security_monitoring_enabled  = try(enhanced_security_compliance.value.enhanced_security_monitoring_enabled, null)
    }
  }

  lifecycle {
    precondition {
      condition     = try(var.settings.access_connector, null) == null || local.access_connector_id != null
      error_message = "The configured Databricks Access Connector reference could not be resolved."
    }

    precondition {
      condition     = try(var.settings.default_storage_firewall_enabled, false) != true || local.access_connector_id != null
      error_message = "default_storage_firewall_enabled requires access_connector_id or a resolvable access_connector reference."
    }

    precondition {
      condition     = local.access_connector_id == null || try(var.settings.default_storage_firewall_enabled, false) == true
      error_message = "An Access Connector can only be configured when default_storage_firewall_enabled is true."
    }

    precondition {
      condition     = try(var.settings.managed_services_cmk_key, null) == null || local.managed_services_cmk_key_vault_key_id != null
      error_message = "The managed_services_cmk_key reference could not be resolved."
    }

    precondition {
      condition     = try(var.settings.managed_disk_cmk_key, null) == null || local.managed_disk_cmk_key_vault_key_id != null
      error_message = "The managed_disk_cmk_key reference could not be resolved."
    }
  }

  dynamic "timeouts" {
    for_each = [try(var.settings.timeouts, {})]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, "60m")
    }
  }
}
