variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Managed Redis instance. This object defines the configuration for Azure Managed Redis deployment.
    The settings object supports the following attributes:
      - name - (Required) The name which should be used for this Managed Redis instance. Changing this forces a new Managed Redis instance to be created.
      - resource_group_key - (Optional) The key of the resource group to deploy the resource in.
      - sku_name - (Required) The SKU name for the Managed Redis instance. Possible values are Balanced_B0 through Balanced_B1000, ComputeOptimized_X3 through ComputeOptimized_X700, FlashOptimized_A250 through FlashOptimized_A4500, MemoryOptimized_M10 through MemoryOptimized_M700.
      - high_availability_enabled - (Optional) Whether to enable high availability for the Managed Redis instance. Defaults to true. Changing this forces a new Managed Redis instance to be created.
      - public_network_access - (Optional) The public network access setting for the Managed Redis instance. Possible values are Enabled and Disabled. Defaults to Enabled.
      - identity - (Optional) An identity block that specifies the configuration for system-assigned or user-assigned managed identities. Supports type, managed_identity_keys for local references, and remote landing-zone identity references.
      - customer_managed_key - (Optional) A customer_managed_key block for encryption with customer-managed keys. Requires key_vault_key_id and user_assigned_identity_id.
      - default_database - (Optional) A default_database block that defines the default Redis database configuration. Supports access_keys_authentication_enabled, client_protocol (Encrypted or Plaintext), clustering_policy (EnterpriseCluster, OSSCluster, or NoCluster), eviction_policy, geo_replication_group_name, persistence settings, and modules.
      - redis_role_assignment - (Optional) A map of role names to role assignment configurations. Each role assignment must include a managed_identities object with keys, a list of managed identity keys to assign the role to. The managed_identities object may also include lz_key, the landing zone key containing those managed identities; when omitted, the current landing zone is used.
      - tags - (Optional) A mapping of tags which should be assigned to the Managed Redis instance.
      - timeouts - (Optional) A timeouts block that defines create, read, update, and delete timeout values.
    DESCRIPTION
  type = object({
    name                      = string
    resource_group_key        = optional(string)
    sku_name                  = string
    high_availability_enabled = optional(bool)
    public_network_access     = optional(string)
    identity = optional(object({
      type                  = string
      managed_identity_keys = optional(list(string))
      remote = optional(map(object({
        managed_identity_keys = list(string)
      })))
    }))
    customer_managed_key = optional(object({
      key_vault_key_id          = string
      user_assigned_identity_id = string
    }))
    default_database = optional(object({
      access_keys_authentication_enabled            = optional(bool)
      client_protocol                               = optional(string)
      clustering_policy                             = optional(string)
      eviction_policy                               = optional(string)
      geo_replication_group_name                    = optional(string)
      persistence_append_only_file_backup_frequency = optional(string)
      persistence_redis_database_backup_frequency   = optional(string)
      modules = optional(list(object({
        name = string
        args = optional(string)
      })))
    }))
    redis_role_assignment = optional(map(object({
      managed_identities = object({
        keys   = list(string)
        lz_key = optional(string)
      })
    })), {})
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    azurecaf_resource_type = optional(string)
  })
  validation {
    condition = length(setsubtract(
      keys(var.settings),
      [
        "name",
        "resource_group_key",
        "sku_name",
        "high_availability_enabled",
        "public_network_access",
        "identity",
        "customer_managed_key",
        "default_database",
        "redis_role_assignment",
        "tags",
        "timeouts",
        "azurecaf_resource_type"
      ]
    )) == 0
    error_message = format("The following attributes are not supported within settings: %s. Allowed attributes are: name, resource_group_key, sku_name, high_availability_enabled, public_network_access, identity, customer_managed_key, default_database, redis_role_assignment, tags, timeouts, azurecaf_resource_type.",
      join(", ",
        setsubtract(
          keys(var.settings),
          [
            "name",
            "resource_group_key",
            "sku_name",
            "high_availability_enabled",
            "public_network_access",
            "identity",
            "customer_managed_key",
            "default_database",
            "redis_role_assignment",
            "tags",
            "timeouts",
            "azurecaf_resource_type"
          ]
        )
      )
    )
  }
}

variable "location" {
  description = "Location override for the resource (defaults to resource group location)."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Optional resource group name override."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resource group object for deployment (expects name, location, tags)."
  type        = any
}

variable "base_tags" {
  description = "Whether to merge base tags (global + resource group) with resource tags."
  type        = bool
  default     = true
}

variable "remote_objects" {
  description = "Remote objects map (diagnostics, keyvaults, etc.)."
  type        = any
  default     = {}
}

variable "diagnostic_profiles" {
  description = "Diagnostic profiles for the resource."
  type        = any
  default     = {}
}

variable "diagnostics" {
  description = "Diagnostics destinations from remote objects."
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Private endpoints configuration for managed redis."
  type        = any
  default     = {}
}

variable "private_dns" {
  description = "Private DNS zones map used by private endpoints. Backward compatibility fallback when remote_objects.private_dns is not provided."
  type        = any
  default     = {}
}

variable "vnets" {
  description = "Virtual networks map used to resolve subnet references for private endpoints. Backward compatibility fallback when remote_objects.vnets is not provided."
  type        = any
  default     = {}
}

variable "virtual_subnets" {
  description = "Virtual subnets map used to resolve subnet references for private endpoints. Backward compatibility fallback when remote_objects.virtual_subnets is not provided."
  type        = any
  default     = {}
}
