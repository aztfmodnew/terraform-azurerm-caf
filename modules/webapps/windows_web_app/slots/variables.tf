variable "global_settings" {
  description = "Global CAF settings used by the Windows Web App slot module for naming and tag inheritance."
  type        = any
}

variable "client_config" {
  description = "Client context used for landing-zone-aware resolution in slot settings."
  type        = any
}

variable "location" {
  description = "Azure location context used by locals/tagging in the slot module."
  type        = string
}


variable "settings" {
  description = <<DESCRIPTION
  Configuration object for `azurerm_windows_web_app_slot`.

  Top-level attributes supported by this module:
  - site_config - (Optional) Site runtime/config block for the slot.
  - app_settings - (Optional) Slot app settings map.
  - connection_string - (Optional) Slot connection string collection.
  - client_affinity_enabled - (Optional) Enables ARR affinity.
  - client_certificate_enabled - (Optional) Enables client certificates.
  - client_certificate_mode - (Optional) Client certificate mode.
  - client_certificate_exclusion_paths - (Optional) Exclusion paths for certificate validation.
  - enabled - (Optional) Enables/disables the slot.
  - ftp_publish_basic_authentication_enabled - (Optional) Enables FTP publishing basic auth.
  - https_only - (Optional) Enforces HTTPS-only traffic.
  - public_network_access_enabled - (Optional) Enables/disables public network access.
  - key_vault_reference_identity_id - (Optional) Direct managed identity ID for Key Vault references.
  - key_vault_reference_identity - (Optional) Object reference to managed identity by `lz_key` and `key`.
  - key_vault_reference_identity_key - (Optional) Backward-compatible key alias for identity resolution.
  - virtual_network_subnet_id - (Optional) Direct subnet ID for VNet integration.
  - virtual_network_subnet - (Optional) Object reference to subnet using `lz_key`, `vnet_key`, and `subnet_key`.
  - identity - (Optional) Managed identity configuration.
  - auth_settings - (Optional) Authentication/authorization v1 block.
  - auth_settings_v2 - (Optional) Authentication/authorization v2 block.
  - backup - (Optional) Backup configuration block.
  - logs - (Optional) App and HTTP logs configuration.
  - sticky_settings - (Optional) Slot-sticky app settings/connection strings.
  - storage_account - (Optional) External storage mounts and related settings.
  - storage_account_key - (Optional) Backward-compatible storage lookup key.
  - webdeploy_publish_basic_authentication_enabled - (Optional) Enables WebDeploy publishing basic auth.
  - zip_deploy_file - (Optional) Local ZIP file path for deployment.
  - timeouts - (Optional) Resource operation timeouts.
  - tags - (Optional) Resource tags merged with CAF base tags.

  Provider reference used for this submodule:
  - hashicorp/azurerm `windows_web_app_slot` (v4.74.0 docs)
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resolved resource group object used by slot locals/tags composition."
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "When true, inherit base tags in addition to module and settings tags."
}

variable "remote_objects" {
  type        = any
  description = <<DESCRIPTION
  Dependency objects for slot provisioning.

  Commonly used entries include:
  - app_service_id (parent Windows Web App ID)
  - managed_identities
  - vnets (and subnets)
  - storage_accounts
  - private_dns
  DESCRIPTION
}


variable "private_endpoints" {
  description = "Private endpoint definitions for the Windows Web App slot."
  type        = any
  default     = {}
}
