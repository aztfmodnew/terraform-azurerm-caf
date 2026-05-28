variable "global_settings" {
  description = <<DESCRIPTION
  Global CAF settings used by this module for naming and inherited tags.

  Typical values consumed by this module:
  - prefixes / suffixes
  - random_length
  - use_slug
  - tags
  DESCRIPTION
  type        = any
}

variable "client_config" {
  description = <<DESCRIPTION
  Client context for the current deployment.

  Used to resolve cross-object references through `remote_objects`, especially
  when a setting points to another landing zone using `lz_key`. When omitted,
  the root module normally derives values from the active provider context.
  DESCRIPTION
  type        = any
}

variable "location" {
  description = "Azure region where the Linux Web App is created. If null at call-site, callers typically coalesce with resource group location."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  Configuration object for the Linux Web App resource (`azurerm_linux_web_app`).

  This module follows CAF patterns and resolves dependencies from `settings` and
  `remote_objects`. Supported top-level attributes include (non-exhaustive):
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

  Nested blocks supported by this module mirror provider capabilities, including:
  - site_config (application_stack, auto_heal_setting, cors, ip_restriction, scm_ip_restriction)
  - auth_settings
  - auth_settings_v2
  - backup
  - connection_string
  - identity
  - logs
  - storage_account
  - sticky_settings
  - timeouts

  Provider reference used for this module:
  - hashicorp/azurerm `linux_web_app` (v4.74.0 docs)
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resolved resource group object used by this module. Expected keys include at least `name`, and typically `location` and optional `tags`."
  type        = any
}

variable "base_tags" {
  description = "When true, merge global/resource-group tags into module tags; when false, only module and explicit settings tags are used."
  type        = bool
}

variable "remote_objects" {
  description = <<DESCRIPTION
  Dependency objects resolved outside this module and injected by the root layer.

  This module can consume, when applicable:
  - service_plans
  - vnets (and subnets)
  - managed_identities
  - storage_accounts
  - diagnostics
  - private_dns

  Keys are usually looked up with `client_config.landingzone_key` unless a
  specific `settings.*.lz_key` override is provided.
  DESCRIPTION
  type        = any
}

variable "private_endpoints" {
  description = "Private endpoint definitions for this web app. Entries are processed by the module's private endpoint integration logic."
  type        = any
  default     = {}
}
