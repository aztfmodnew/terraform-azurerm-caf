variable "settings" {
  description = <<DESCRIPTION
    Settings for an Azure Databricks workspace.
    - name - (Required) Workspace name.
    - sku - (Optional) standard, premium, or trial. Defaults to standard.
    - resource_group_key, resource_group, resource_group_name, lz_key - (Optional) CAF resource group references.
    - location, region - (Optional) Azure location or key in global_settings.regions. The resource group location is used when neither is supplied.
    - managed_resource_group_name - (Optional) Name for the Azure-managed resource group.
    - load_balancer_backend_address_pool_id - (Optional) Outbound load balancer backend pool ID for secure cluster connectivity.
    - customer_managed_key_enabled - (Optional) Enables managed storage customer-managed encryption; premium only. Defaults to false.
    - infrastructure_encryption_enabled - (Optional) Enables a secondary encryption layer; premium only. Defaults to false.
    - managed_services_cmk_key_vault_id and managed_services_cmk_key_vault_key_id - (Optional) Key Vault and key IDs for managed services encryption.
    - managed_disk_cmk_key_vault_id and managed_disk_cmk_key_vault_key_id - (Optional) Key Vault and key IDs for managed disk encryption.
    - managed_services_cmk_key and managed_disk_cmk_key - (Optional) CAF key references resolved from remote_objects.keyvault_keys.
    - managed_disk_cmk_rotation_to_latest_version_enabled - (Optional) Enables automatic rotation of managed disk encryption keys.
    - public_network_access_enabled - (Optional) Allows public access to the workspace. Defaults to true.
    - default_storage_firewall_enabled - (Optional) Disallows public access to default storage. Defaults to false.
    - access_connector_id - (Optional) Access Connector resource ID required when the default storage firewall is enabled.
    - access_connector - (Optional) CAF Access Connector reference with key and optional lz_key.
    - network_security_group_rules_required - (Optional) AllRules, NoAzureDatabricksRules, or NoAzureServiceRules.
    - custom_parameters - (Optional) VNet injection, cluster connectivity, storage, and AML workspace settings.
    - enhanced_security_compliance - (Optional) Premium enhanced security and compliance settings.
    - root_dbfs_customer_managed_key - (Optional) Creates the separate root DBFS customer-managed key resource. The workspace must have customer_managed_key_enabled=true and its Databricks storage identity must be authorized on the key.
    - diagnostic_profiles - (Optional) Diagnostic settings profiles.
    - tags - (Optional) Additional resource tags.
    - timeouts - (Optional) Workspace create/read/update/delete timeouts. The existing 60-minute delete timeout is retained when omitted.
    - azurecaf_resource_type - (Optional) Override for the AzureCAF resource type used to generate the workspace name.

    custom_parameters supports machine_learning_workspace_id or machine_learning_workspace (CAF key reference), nat_gateway_name, public_ip_name, no_public_ip, public_subnet_name, public_subnet_network_security_group_association_id, private_subnet_name, private_subnet_network_security_group_association_id, storage_account_name, storage_account_sku_name, virtual_network_id, and vnet_address_prefix. It also supports vnet_key, public_subnet_key, private_subnet_key, and lz_key for CAF network resolution. The module retains no_public_ip=false when omitted for backward compatibility.
    enhanced_security_compliance supports automatic_cluster_update_enabled, compliance_security_profile_enabled, compliance_security_profile_standards, and enhanced_security_monitoring_enabled. A compliance security profile requires automatic cluster updates and enhanced security monitoring.
  DESCRIPTION
  type = object({
    name                = string
    sku                 = optional(string)
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    lz_key                                = optional(string)
    location                              = optional(string)
    region                                = optional(string)
    managed_resource_group_name           = optional(string)
    load_balancer_backend_address_pool_id = optional(string)
    customer_managed_key_enabled          = optional(bool)
    infrastructure_encryption_enabled     = optional(bool)
    managed_services_cmk_key_vault_id     = optional(string)
    managed_services_cmk_key_vault_key_id = optional(string)
    managed_services_cmk_key = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    managed_disk_cmk_key_vault_id     = optional(string)
    managed_disk_cmk_key_vault_key_id = optional(string)
    managed_disk_cmk_key = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    managed_disk_cmk_rotation_to_latest_version_enabled = optional(bool)
    public_network_access_enabled                       = optional(bool)
    default_storage_firewall_enabled                    = optional(bool)
    access_connector_id                                 = optional(string)
    access_connector = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    network_security_group_rules_required = optional(string)
    custom_parameters = optional(object({
      machine_learning_workspace_id = optional(string)
      machine_learning_workspace = optional(object({
        id     = optional(string)
        key    = optional(string)
        lz_key = optional(string)
      }))
      machine_learning = optional(object({
        id     = optional(string)
        key    = optional(string)
        lz_key = optional(string)
      }))
      nat_gateway_name                                     = optional(string)
      public_ip_name                                       = optional(string)
      no_public_ip                                         = optional(bool)
      public_subnet_name                                   = optional(string)
      public_subnet_network_security_group_association_id  = optional(string)
      private_subnet_name                                  = optional(string)
      private_subnet_network_security_group_association_id = optional(string)
      storage_account_name                                 = optional(string)
      storage_account_sku_name                             = optional(string)
      virtual_network_id                                   = optional(string)
      vnet_address_prefix                                  = optional(string)
      vnet_key                                             = optional(string)
      public_subnet_key                                    = optional(string)
      private_subnet_key                                   = optional(string)
      lz_key                                               = optional(string)
    }))
    enhanced_security_compliance = optional(object({
      automatic_cluster_update_enabled      = optional(bool)
      compliance_security_profile_enabled   = optional(bool)
      compliance_security_profile_standards = optional(list(string))
      enhanced_security_monitoring_enabled  = optional(bool)
    }))
    root_dbfs_customer_managed_key = optional(object({
      key_vault_key_id = optional(string)
      key_vault_id     = optional(string)
      key_vault_key = optional(object({
        key    = string
        lz_key = optional(string)
      }))
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    }))
    machine_learning = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    diagnostic_profiles    = optional(map(any))
    tags                   = optional(map(string))
    azurecaf_resource_type = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name",
      "sku",
      "resource_group_key",
      "resource_group_name",
      "resource_group",
      "lz_key",
      "location",
      "region",
      "managed_resource_group_name",
      "load_balancer_backend_address_pool_id",
      "customer_managed_key_enabled",
      "infrastructure_encryption_enabled",
      "managed_services_cmk_key_vault_id",
      "managed_services_cmk_key_vault_key_id",
      "managed_services_cmk_key",
      "managed_disk_cmk_key_vault_id",
      "managed_disk_cmk_key_vault_key_id",
      "managed_disk_cmk_key",
      "managed_disk_cmk_rotation_to_latest_version_enabled",
      "public_network_access_enabled",
      "default_storage_firewall_enabled",
      "access_connector_id",
      "access_connector",
      "network_security_group_rules_required",
      "custom_parameters",
      "enhanced_security_compliance",
      "root_dbfs_customer_managed_key",
      "machine_learning",
      "diagnostic_profiles",
      "tags",
      "azurecaf_resource_type",
      "timeouts"
    ])) == 0
    error_message = "Unsupported Databricks workspace settings were provided."
  }

  validation {
    condition     = try(contains(["standard", "premium", "trial"], var.settings.sku), true)
    error_message = "sku must be standard, premium, or trial."
  }

  validation {
    condition = try(
      (var.settings.customer_managed_key_enabled != true && var.settings.infrastructure_encryption_enabled != true && var.settings.enhanced_security_compliance == null) ||
      lower(coalesce(var.settings.sku, "standard")) == "premium",
      true
    )
    error_message = "Customer-managed keys, infrastructure encryption, and enhanced security compliance require sku = \"premium\"."
  }

  validation {
    condition = try(
      var.settings.public_network_access_enabled != false || var.settings.network_security_group_rules_required != null,
      true
    )
    error_message = "network_security_group_rules_required must be set when public_network_access_enabled is false."
  }

  validation {
    condition = try(
      var.settings.network_security_group_rules_required == null ||
      contains(["AllRules", "NoAzureDatabricksRules", "NoAzureServiceRules"], var.settings.network_security_group_rules_required),
      true
    )
    error_message = "network_security_group_rules_required must be AllRules, NoAzureDatabricksRules, or NoAzureServiceRules."
  }

  validation {
    condition = try(
      var.settings.enhanced_security_compliance == null ||
      var.settings.enhanced_security_compliance.compliance_security_profile_enabled != true ||
      (
        var.settings.enhanced_security_compliance.automatic_cluster_update_enabled == true &&
        var.settings.enhanced_security_compliance.enhanced_security_monitoring_enabled == true
      ),
      true
    )
    error_message = "compliance_security_profile_enabled requires automatic_cluster_update_enabled and enhanced_security_monitoring_enabled to be true."
  }

  validation {
    condition = try(
      var.settings.enhanced_security_compliance == null ||
      var.settings.enhanced_security_compliance.compliance_security_profile_standards == null ||
      var.settings.enhanced_security_compliance.compliance_security_profile_enabled == true,
      true
    )
    error_message = "compliance_security_profile_standards can only be set when compliance_security_profile_enabled is true."
  }

  validation {
    condition = try(
      var.settings.enhanced_security_compliance.compliance_security_profile_standards == null ||
      alltrue([
        for standard in var.settings.enhanced_security_compliance.compliance_security_profile_standards :
        contains([
          "HIPAA",
          "PCI_DSS",
          "FEDRAMP_MODERATE",
          "IRAP_PROTECTED",
          "FEDRAMP_HIGH",
          "FEDRAMP_IL5",
          "ITAR_EAR",
          "CYBER_ESSENTIAL_PLUS",
          "CANADA_PROTECTED_B",
          "ISMAP",
          "HITRUST",
          "K_FSI",
          "GERMANY_C5",
          "GERMANY_TISAX"
        ], standard)
      ]),
      true
    )
    error_message = "compliance_security_profile_standards contains an unsupported standard."
  }
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "vnets" {
  description = "Virtual networks objects - contains all virtual networks that could potentially be used by the module."
}

variable "aml" {
  description = "Azure Machine Learning objects - contains all AML workspaces that could potentially be used by the module."
}

variable "diagnostics" {
  description = "(Required) Diagnostics object with the definitions and destination services"
}

variable "private_endpoints" {
  default = {}
}

variable "resource_groups" {
  default = {}
}

variable "private_dns" {
  default = {}
}
variable "remote_objects" {
  description = "Remote CAF objects used to resolve Key Vault keys and Databricks Access Connectors."
  type        = any
  default     = {}
}
variable "location" {
  description = "location of the resource if different from the resource group."
  type        = string
  default     = null
}
variable "resource_group_name" {
  description = "Resource group object to deploy the Azure resource"
  type        = string
  default     = null
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
