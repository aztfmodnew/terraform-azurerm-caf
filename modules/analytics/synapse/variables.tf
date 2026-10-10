variable "settings" {
  description = <<DESCRIPTION
Settings for an Azure Synapse workspace.

Required:
  - name - Workspace name input used by CAF naming.

Optional:
  - resource_group_key, resource_group_name, resource_group, lz_key - Resource group reference or explicit name and landing-zone key.
  - location, region - Workspace location override or CAF region key.
  - storage_data_lake_gen2_filesystem_id, data_lake_filesystem - Direct filesystem ID or CAF storage-account/container keys.
  - keyvault_key - Key Vault key used to store generated SQL administrator credentials.
  - sql_administrator_login, sql_administrator_login_password - SQL administrator credentials. If a login is configured without a password, a password is generated and stored in Key Vault. A login may be omitted when a customer-managed key is configured.
  - sql_administrator_login_password_not_before, sql_administrator_login_password_expiration_date - Secret validity dates.
  - azuread_authentication_only - Enables Microsoft Entra-only authentication.
  - compute_subnet_id, compute_subnet - Direct compute subnet ID or CAF VNet/subnet keys.
  - data_exfiltration_protection_enabled - Enables data exfiltration protection; requires a managed virtual network.
  - customer_managed_key_versionless_id, customer_managed_key, customer_managed_key_key_name, customer_managed_key_user_assigned_identity_id - Customer-managed encryption key configuration; the key ID must be versionless.
  - azure_devops_repo, github_repo - Optional Git integration; configure at most one.
  - linking_allowed_for_aad_tenant_ids - Tenant IDs allowed to link to the workspace.
  - managed_resource_group_name - Name for the workspace-managed resource group.
  - managed_virtual_network_enabled - Enables the Synapse managed virtual network.
  - public_network_access_enabled - Enables public network access.
  - purview_id - Azure Purview resource ID linked to the workspace.
  - sql_identity_control_enabled - Enables SQL identity control.
  - identity - System-assigned and/or user-assigned managed identity configuration. User-assigned identities accept direct IDs or CAF local/remote identity keys.
  - timeouts - Create, read, update, and delete timeouts for the workspace.
  - key_vault_secret_timeouts - Create, read, update, and delete timeouts for generated Key Vault secrets.
  - workspace_firewall - Legacy single firewall rule; retained for compatibility.
  - workspace_firewalls - Map of firewall rules; each rule may set a name and timeouts.
  - aad_admin - Optional workspace Microsoft Entra administrator and timeouts.
  - synapse_spark_pools, synapse_sql_pools - Maps of child pool configurations.
  - private_endpoints - Map of private endpoint configurations.
  - tags - Additional tags applied to the workspace and generated secrets.
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
    lz_key                               = optional(string)
    location                             = optional(string)
    region                               = optional(string)
    storage_data_lake_gen2_filesystem_id = optional(string)
    data_lake_filesystem = optional(object({
      storage_account_key = optional(string)
      container_key       = optional(string)
    }))
    keyvault_key                                     = optional(string)
    sql_administrator_login                          = optional(string)
    sql_administrator_login_password                 = optional(string)
    sql_administrator_login_password_not_before      = optional(string)
    sql_administrator_login_password_expiration_date = optional(string)
    azuread_authentication_only                      = optional(bool)
    compute_subnet_id                                = optional(string)
    compute_subnet = optional(object({
      id       = optional(string)
      key      = optional(string)
      vnet_key = optional(string)
      lz_key   = optional(string)
    }))
    data_exfiltration_protection_enabled = optional(bool)
    customer_managed_key_versionless_id  = optional(string)
    customer_managed_key = optional(object({
      key_versionless_id        = string
      key_name                  = optional(string)
      user_assigned_identity_id = optional(string)
    }))
    customer_managed_key_key_name                  = optional(string)
    customer_managed_key_user_assigned_identity_id = optional(string)
    azure_devops_repo = optional(object({
      account_name    = string
      branch_name     = string
      last_commit_id  = optional(string)
      project_name    = string
      repository_name = string
      root_folder     = string
      tenant_id       = optional(string)
    }))
    github_repo = optional(object({
      account_name    = string
      branch_name     = string
      last_commit_id  = optional(string)
      repository_name = string
      root_folder     = string
      git_url         = optional(string)
    }))
    linking_allowed_for_aad_tenant_ids = optional(list(string))
    managed_resource_group_name        = optional(string)
    managed_virtual_network_enabled    = optional(bool)
    public_network_access_enabled      = optional(bool)
    purview_id                         = optional(string)
    sql_identity_control_enabled       = optional(bool)
    identity = optional(object({
      type                  = string
      identity_ids          = optional(list(string))
      managed_identity_keys = optional(list(string), [])
      remote = optional(map(object({
        managed_identity_keys = optional(list(string), [])
      })), {})
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    key_vault_secret_timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    workspace_firewall = optional(object({
      name     = string
      start_ip = string
      end_ip   = string
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    }))
    workspace_firewalls = optional(map(object({
      name     = optional(string)
      start_ip = string
      end_ip   = string
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    aad_admin = optional(object({
      login     = string
      object_id = string
      tenant_id = string
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    }))
    synapse_spark_pools = optional(map(any), {})
    synapse_sql_pools   = optional(map(any), {})
    private_endpoints   = optional(map(any), {})
    tags                = optional(map(string), {})
  })

  validation {
    condition = (
      try(var.settings.sql_administrator_login, null) != null ||
      try(var.settings.customer_managed_key_versionless_id, null) != null ||
      try(var.settings.customer_managed_key.key_versionless_id, null) != null
    )
    error_message = "Configure sql_administrator_login or a customer-managed key."
  }

  validation {
    condition = (
      !coalesce(try(var.settings.data_exfiltration_protection_enabled, null), false) ||
      coalesce(try(var.settings.managed_virtual_network_enabled, null), true)
    )
    error_message = "data_exfiltration_protection_enabled requires managed_virtual_network_enabled to be true."
  }

  validation {
    condition = (
      try(var.settings.azure_devops_repo, null) == null ||
      try(var.settings.github_repo, null) == null
    )
    error_message = "Configure at most one of azure_devops_repo and github_repo."
  }

  validation {
    condition = (
      try(var.settings.identity.type, null) == null ||
      contains(
        ["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"],
        coalesce(try(var.settings.identity.type, null), "SystemAssigned")
      )
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition = (
      !contains(
        ["UserAssigned", "SystemAssigned, UserAssigned"],
        coalesce(try(var.settings.identity.type, null), "SystemAssigned")
      ) ||
      length(coalesce(try(var.settings.identity.identity_ids, null), [])) > 0 ||
      length(coalesce(try(var.settings.identity.managed_identity_keys, null), [])) > 0 ||
      length(flatten([
        for remote_identity in coalesce(try(var.settings.identity.remote, null), {}) :
        coalesce(try(remote_identity.managed_identity_keys, null), [])
      ])) > 0
    )
    error_message = "A user-assigned identity type requires identity_ids or managed identity keys."
  }
}

variable "global_settings" {
  description = "Global CAF naming and tag settings."
  type        = any
}

variable "client_config" {
  description = "Client configuration object used to resolve landing-zone references."
  type        = any
}

variable "remote_objects" {
  description = "Remote CAF objects used for managed identity resolution."
  type        = any
  default     = {}
}

variable "storage_data_lake_gen2_filesystem_id" {
  description = "The ID of the Data Lake Storage Gen2 filesystem used by Synapse."
  type        = string
}

variable "keyvault_id" {
  description = "The ID of the Key Vault used to store generated SQL administrator credentials."
  type        = string
  default     = null
}

variable "vnets" {
  description = "Combined virtual network objects used for subnet references."
  type        = map(any)
  default     = {}
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

variable "location" {
  description = "Azure location override for the workspace."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group name override for the workspace."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resolved resource group object for the workspace."
  type        = any
}

variable "base_tags" {
  description = "Whether to inherit tags from global settings and the resource group."
  type        = bool
}
