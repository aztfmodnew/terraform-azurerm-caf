variable "settings" {
  description = <<-DESCRIPTION
    Configuration for an Azure Machine Learning workspace.
    Supports the AzureRM workspace arguments and nested blocks, CAF managed
    identity references, diagnostic profiles, private endpoints, managed
    network outbound rules, and the legacy compute_instances child module.

    Required:
      - name - (string) Workspace name passed to azurecaf for CAF naming.

    Dependency resolution (supply exactly one form per dependency):
      - resource_group_key / resource_group_name / resource_group - resource group
        reference. The object form additionally accepts lz_key, name and location.
      - storage_account_key, keyvault_key, application_insights_key and
        container_registry_key - CAF keys resolved through remote_objects, or
        container_registry_id for a direct resource id.
      - lz_key - landing zone key used for every *_key lookup above.

    Frequently used optional arguments (null unless noted):
      - location / region - region override; defaults to the resource group region.
      - sku_name, description, friendly_name, high_business_impact.
      - public_network_access_enabled - (bool) defaults to the provider default of true.
      - service_side_encryption_enabled - (bool) AzureRM declares RequiredWith on
        encryption, so the encryption block is mandatory when this is true. The
        reverse is not true: an encryption block alone is valid.
      - identity - (object) type plus identity_ids and/or CAF managed_identity_keys
        and remote references.
      - encryption - (object) key_vault_id and key_id are required,
        user_assigned_identity_id is optional.
      - managed_network - (object) isolation_mode and provision_on_creation_enabled.
      - feature_store - (object) required when kind is FeatureStore.
      - serverless_compute - (object) subnet_id and public_ip_enabled. AzureRM rejects
        public_ip_enabled = false when subnet_id is unset and public network access is
        disabled, so the module defaults public_ip_enabled to true in that case and to
        the provider default of false otherwise. AzureRM also forbids updating
        public_ip_enabled from true to false while subnet_id is unset.
      - network_outbound_rules - (object) fqdn, private_endpoint and service_tag maps,
        each requiring azurerm 4.15.0 or newer.
      - tags - (map(string)) merged on top of the CAF inherited tags.
      - timeouts - (object) create, read, update and delete.
  DESCRIPTION

  type = object({
    name                = string
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      name     = optional(string)
      location = optional(string)
    }))
    lz_key                          = optional(string)
    storage_account_key             = optional(string)
    keyvault_key                    = optional(string)
    application_insights_key        = optional(string)
    container_registry_key          = optional(string)
    container_registry_id           = optional(string)
    location                        = optional(string)
    region                          = optional(string)
    sku_name                        = optional(string)
    description                     = optional(string)
    friendly_name                   = optional(string)
    high_business_impact            = optional(bool)
    public_network_access_enabled   = optional(bool)
    kind                            = optional(string)
    image_build_compute_name        = optional(string)
    primary_user_assigned_identity  = optional(string)
    v1_legacy_mode_enabled          = optional(bool)
    storage_account_access_type     = optional(string)
    service_side_encryption_enabled = optional(bool)
    identity = optional(object({
      type                  = optional(string)
      identity_ids          = optional(list(string), [])
      managed_identity_keys = optional(list(string), [])
      remote                = optional(map(any), {})
    }))
    encryption = optional(object({
      key_vault_id              = string
      key_id                    = string
      user_assigned_identity_id = optional(string)
    }))
    managed_network = optional(object({
      isolation_mode                = optional(string)
      provision_on_creation_enabled = optional(bool)
    }))
    feature_store = optional(object({
      computer_spark_runtime_version = optional(string)
      offline_connection_name        = optional(string)
      online_connection_name         = optional(string)
    }))
    serverless_compute = optional(object({
      subnet_id         = optional(string)
      public_ip_enabled = optional(bool)
    }))
    network_outbound_rules = optional(object({
      fqdn = optional(map(object({
        name             = optional(string)
        destination_fqdn = string
        timeouts = optional(object({
          create = optional(string)
          read   = optional(string)
          update = optional(string)
          delete = optional(string)
        }))
      })), {})
      private_endpoint = optional(map(object({
        name                = optional(string)
        service_resource_id = string
        sub_resource_target = string
        spark_enabled       = optional(bool)
        timeouts = optional(object({
          create = optional(string)
          read   = optional(string)
          delete = optional(string)
        }))
      })), {})
      service_tag = optional(map(object({
        name        = optional(string)
        service_tag = string
        protocol    = string
        port_ranges = string
        timeouts = optional(object({
          create = optional(string)
          read   = optional(string)
          update = optional(string)
          delete = optional(string)
        }))
      })), {})
    }))
    diagnostic_profiles = optional(map(any), {})
    private_endpoints   = optional(map(any), {})
    compute_instances   = optional(map(any), {})
    tags                = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = (
      coalesce(try(var.settings.service_side_encryption_enabled, null), false) == false ||
      try(var.settings.encryption, null) != null
    )
    error_message = "The encryption block must be configured when service_side_encryption_enabled is true."
  }

  validation {
    condition = (
      coalesce(try(var.settings.kind, null), "Default") != "FeatureStore" ||
      try(var.settings.feature_store, null) != null
    )
    error_message = "The feature_store block must be configured when kind is FeatureStore."
  }
}

variable "client_config" {
  description = "Client configuration object used to resolve landing zone references."
  type        = any
}

variable "global_settings" {
  description = "Global CAF settings."
  type        = any
}

variable "resource_groups" {
  description = "Combined resource group objects used by CAF key references."
  type        = map(any)
  default     = {}
}

variable "keyvault_id" {
  description = "Key Vault ID associated with the workspace."
  type        = string
}

variable "storage_account_id" {
  description = "Storage account ID associated with the workspace."
  type        = string
}

variable "application_insights_id" {
  description = "Application Insights ID associated with the workspace."
  type        = string
}

variable "container_registry_id" {
  description = "Optional container registry ID associated with the workspace."
  type        = string
  default     = null
}

variable "base_tags" {
  description = "Inherited tags to apply to the workspace."
  type        = map(any)
  default     = {}
}

variable "vnets" {
  description = "Combined virtual network objects used for subnet references."
  type        = map(any)
  default     = {}
}

variable "diagnostics" {
  description = "Combined diagnostic definitions and destination objects."
  type        = any
  default = {
    diagnostics_definition   = {}
    diagnostics_destinations = {}
    storage_accounts         = {}
    log_analytics            = {}
    event_hub_namespaces     = {}
  }
}

variable "private_endpoints" {
  description = "Private endpoint configurations for the workspace."
  type        = map(any)
  default     = {}
}

variable "private_dns" {
  description = "Combined private DNS zone objects used by private endpoints."
  type        = map(any)
  default     = {}
}

variable "remote_objects" {
  description = "Remote CAF objects used to resolve managed identities."
  type        = any
  default     = {}
}
