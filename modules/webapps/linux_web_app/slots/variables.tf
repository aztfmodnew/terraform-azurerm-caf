variable "global_settings" {
  description = "Global CAF settings used by the Linux Web App slot module for naming and tag inheritance."
  type        = any
}

variable "client_config" {
  description = "Client context used for cross-landing-zone dependency resolution in slot settings."
  type        = any
}

variable "location" {
  description = "Azure location for the slot context (used by locals and tagging patterns)."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  Configuration object for the Linux Web App Slot (`azurerm_linux_web_app_slot`).

  Supported top-level attributes include (non-exhaustive):
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
  - storage_account
  - sticky_settings
  - timeouts

  Provider reference used for this submodule:
  - hashicorp/azurerm `linux_web_app_slot` (v4.74.0 docs)
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resolved resource group object for slot-related tag/location composition."
  type        = any
}

variable "base_tags" {
  description = "When true, inherit base tags in addition to module and settings tags."
  type        = bool
}

variable "remote_objects" {
  description = <<DESCRIPTION
  Dependency objects for slot provisioning.

  Required/commonly used entries include:
  - app_service_id (ID of parent Linux Web App)
  - managed_identities
  - vnets (and subnets)
  - storage_accounts
  - private_dns
  DESCRIPTION
  type        = any
}

variable "private_endpoints" {
  description = "Private endpoint definitions for the slot resource."
  type        = any
  default     = {}
}
