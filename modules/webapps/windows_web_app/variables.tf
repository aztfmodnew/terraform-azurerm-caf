variable "global_settings" {
  description = "Global CAF settings used for naming and optional inherited tags in the Windows Web App module."
  type        = any
}

variable "client_config" {
  description = "Client context used to resolve landing-zone-aware references through `remote_objects`."
  type        = any
}

variable "location" {
  description = "Azure region where the Windows Web App is created. Callers commonly coalesce with the target resource group location."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  Configuration object for `azurerm_windows_web_app`.

  Supported top-level attributes include (non-exhaustive):
  - service_plan_id / service_plan(.lz_key, .key)
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
  - site_config (application_stack, auto_heal_setting, cors, ip_restriction, scm_ip_restriction)
  - auth_settings
  - auth_settings_v2
  - backup
  - connection_string
  - identity
  - logs
  - sticky_settings
  - storage_account
  - timeouts

  Provider reference used for this module:
  - hashicorp/azurerm `windows_web_app` (v4.74.0 docs)
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resolved resource group object for this module. Expected keys include `name`, and typically `location` and optional `tags`."
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "When true, merge global/resource-group tags with module and settings tags."
}

variable "remote_objects" {
  type        = any
  description = <<DESCRIPTION
  Dependency objects injected from root aggregators.

  This module commonly consumes:
  - service_plans
  - managed_identities
  - vnets (and subnets)
  - storage_accounts
  - diagnostics
  - private_dns

  Keys are resolved through `client_config.landingzone_key` unless overridden
  with `settings.*.lz_key`.
  DESCRIPTION
}

variable "private_endpoints" {
  description = "Private endpoint definitions for the Windows Web App."
  type        = any
  default     = {}
}
