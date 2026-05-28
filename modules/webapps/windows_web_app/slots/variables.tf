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

  Supported top-level attributes include (non-exhaustive):
  - app_settings
  - client_affinity_enabled
  - client_certificate_enabled
  - client_certificate_mode
  - client_certificate_exclusion_paths
  - enabled
  - ftp_publish_basic_authentication_enabled
  - https_only
  - public_network_access_enabled
  - key_vault_reference_identity_id / key_vault_reference_identity(.lz_key, .key)
  - virtual_network_subnet_id / virtual_network_subnet(.lz_key, .vnet_key, .subnet_key)
  - webdeploy_publish_basic_authentication_enabled
  - zip_deploy_file
  - tags

  Nested blocks implemented by this module include:
  - site_config
  - auth_settings
  - auth_settings_v2
  - backup
  - connection_string
  - identity
  - logs
  - sticky_settings
  - storage_account
  - timeouts

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
