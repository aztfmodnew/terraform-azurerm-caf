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

  Top-level attributes supported by this module:
  - name - (Required for CAF naming) Base resource name used by azurecaf naming generation.
  - service_plan_id - (Optional) Direct App Service Plan ID.
  - service_plan - (Optional) Object reference to plan by `lz_key` and `key`.
  - service_plan_key - (Optional) Backward-compatible key alias used with `service_plan` resolution.
  - site_config - (Optional) Site runtime/config block (application stack, restrictions, TLS, worker, etc.).
  - app_settings - (Optional) Application settings map.
  - dynamic_app_settings - (Optional) Dynamic app settings resolved from remote combined objects.
  - connection_strings - (Optional) Connection string collection consumed by module locals and rendered into `connection_string` blocks.
  - client_affinity_enabled - (Optional) Enables ARR affinity.
  - client_certificate_enabled - (Optional) Enables client certificates.
  - client_certificate_mode - (Optional) Client certificate mode.
  - client_certificate_exclusion_paths - (Optional) Exclusion paths for certificate validation.
  - enabled - (Optional) Enables/disables the web app.
  - ftp_publish_basic_authentication_enabled - (Optional) Enables FTP publishing basic auth.
  - https_only - (Optional) Enforces HTTPS-only traffic.
  - public_network_access_enabled - (Optional) Enables/disables public network access.
  - application_insight - (Optional) Toggle object used by module locals to enable App Insights app settings injection.
  - application_insights - (Optional) Source object for App Insights values (`key`, optional `lz_key`, or direct `instrumentation_key`/`connection_string`) consumed when `application_insight` is provided.
  - key_vault_reference_identity_id - (Optional) Direct managed identity ID for Key Vault references.
  - key_vault_reference_identity - (Optional) Object reference to managed identity by `key` (landing zone currently resolved via `settings.identity.lz_key` compatibility path in implementation).
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
  - slots - (Optional) Map of slot definitions passed to the slot submodule.
  - diagnostic_profiles - (Optional) Diagnostics profile references consumed by diagnostics integration.

  Provider reference used for this module:
  - hashicorp/azurerm `windows_web_app` (v4.74.0 docs)

  Compatibility note:
  - Current implementation reads `microsoft_v2` compatibility fields from `settings.auth_settings.microsoft_v2`.
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
