variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  Settings object for the Windows Function App Slot (`azurerm_windows_function_app_slot`).
  The attributes below describe what this submodule actually consumes.

  Core attributes:
  - name - (Required) Base slot name used by `azurecaf_name`.
  - tags - (Optional) Extra tags merged with base tags.
  - diagnostic_profiles - (Optional) Map of diagnostic profile objects consumed by `diagnostics.tf`.

  App settings composition:
  - app_settings - (Optional) Map of app settings merged into final app settings.
  - dynamic_app_settings - (Optional) Map used to resolve app settings from `remote_objects.combined_objects`.
  Structure:
    dynamic_app_settings = {
    "SETTING_NAME" = {
      <resource_type_key> = {
      <object_key> = {
        lz_key        = "<landingzone_key>" # optional, defaults to current landing zone
        attribute_key = "<attribute_name>"
      }
      }
    }
    }
  - application_insight - (Optional) Presence flag object used by locals to enable Application Insights injection.
  - application_insights - (Optional) Object used to resolve instrumentation/connection values:
    - key - (Optional) Remote object key.
    - lz_key - (Optional) Landing zone key.
    - instrumentation_key - (Optional) Direct fallback instrumentation key.
    - connection_string - (Optional) Direct fallback connection string.

  Resource arguments (top-level):
  - builtin_logging_enabled - (Optional) Built-in logging toggle. Provider default: true.
  - client_certificate_enabled - (Optional) Client certificate requirement toggle.
  - client_certificate_mode - (Optional) One of `Required`, `Optional`, `OptionalInteractiveUser`.
  - client_certificate_exclusion_paths - (Optional) `;` separated paths excluded from client-certificate checks.
  - content_share_force_disabled - (Optional) Disable content share settings.
  - daily_memory_time_quota - (Optional) Daily quota in GB-seconds. Provider default: 0.
  - enabled - (Optional) Function app slot enabled flag. Provider default: true.
  - ftp_publish_basic_authentication_enabled - (Optional) FTP basic auth publishing profile toggle. Provider default: true.
  - functions_extension_version - (Optional) Runtime version. Provider default: `~4`.
  - https_only - (Optional) HTTPS-only toggle.
  - public_network_access_enabled - (Optional) Public network access toggle. Provider default: true.
  - key_vault_reference_identity_id - (Optional) Direct user-assigned identity ID for Key Vault references.
  - key_vault_reference_identity - (Optional) Remote identity reference:
    - key - (Required when used) Managed identity key.
    - lz_key - (Optional) Landing zone key.

  site_config block (`settings.site_config`):
  - always_on - (Optional) Always On setting.
  - api_definition_url - (Optional) API definition URL.
  - api_management_api_id - (Optional) Direct APIM API ID.
  - api_management_api - (Optional) Remote APIM API reference object:
    - key - (Required when used)
    - lz_key - (Optional)
  - app_command_line - (Optional) Startup command line.
  - app_scale_limit - (Optional) Scale-out worker limit.
  - application_insights_connection_string - (Optional) App Insights connection string.
  - application_insights_key - (Optional) App Insights instrumentation key.
  - application_stack - (Optional) Runtime stack object:
    - dotnet_version
    - use_dotnet_isolated_runtime
    - java_version
    - node_version
    - powershell_core_version
    - use_custom_runtime
  - app_service_logs - (Optional) App service log settings:
    - disk_quota_mb
    - retention_period_days
  - cors - (Optional) CORS settings:
    - allowed_origins
    - support_credentials
  - default_documents - (Optional) Default document list.
  - elastic_instance_minimum - (Optional) Minimum Elastic Premium instances.
  - ftps_state - (Optional) One of `AllAllowed`, `FtpsOnly`, `Disabled`.
  - health_check_path - (Optional) Health check path.
  - health_check_eviction_time_in_min - (Optional) Health check eviction minutes.
  - ip_restriction - (Optional) List of IP restriction objects:
    - action, ip_address, name, priority, service_tag, virtual_network_subnet_id, description
    - headers (optional): x_azure_fdid, x_fd_health_probe, x_forwarded_for, x_forwarded_host
  - ip_restriction_default_action - (Optional) `Allow` or `Deny`.
  - load_balancing_mode - (Optional) App Service load balancing mode.
  - managed_pipeline_mode - (Optional) `Integrated` or `Classic`.
  - minimum_tls_version - (Optional) `1.0`, `1.1`, `1.2`, `1.3`.
  - pre_warmed_instance_count - (Optional) Pre-warmed instance count.
  - remote_debugging_enabled - (Optional) Remote debugging toggle.
  - remote_debugging_version - (Optional) Remote debugging version (for example `VS2022`).
  - runtime_scale_monitoring_enabled - (Optional) Functions runtime scale monitoring toggle.
  - scm_ip_restriction - (Optional) List of SCM IP restriction objects (same shape as ip_restriction).
  - scm_ip_restriction_default_action - (Optional) SCM default action (`Allow`/`Deny`).
  - scm_minimum_tls_version - (Optional) SCM minimum TLS version.
  - scm_use_main_ip_restriction - (Optional) Reuse main IP restrictions for SCM.
  - use_32_bit_worker - (Optional) 32-bit worker toggle.
  - vnet_route_all_enabled - (Optional) Route all outbound traffic through VNet integration.
  - websockets_enabled - (Optional) WebSockets toggle.
  - worker_count - (Optional) Worker count.

  auth_settings block (`settings.auth_settings`):
  - enabled - (Required when block is used)
  - active_directory - (Optional): client_id, client_secret, allowed_audiences
  - additional_login_parameters - (Optional)
  - allowed_external_redirect_urls - (Optional)
  - default_provider - (Optional)
  - facebook - (Optional): app_id, app_secret, app_secret_setting_name, oauth_scopes
  - github - (Optional): client_id, client_secret, client_secret_setting_name, oauth_scopes
  - google - (Optional): client_id, client_secret, client_secret_setting_name, oauth_scopes
  - twitter - (Optional): consumer_key, consumer_secret, consumer_secret_setting_name
  - issuer - (Optional)
  - microsoft - (Optional): client_id, client_secret, client_secret_setting_name, oauth_scopes
  - runtime_version - (Optional)
  - token_refresh_extension_hours - (Optional) Provider default: 72
  - token_store_enabled - (Optional) Provider default: false
  - unauthenticated_client_action - (Optional)

  auth_settings_v2 block (`settings.auth_settings_v2`):
  - auth_enabled - (Optional) Provider default: false
  - runtime_version - (Optional) Provider default: `~1`
  - config_file_path - (Optional)
  - require_authentication - (Optional)
  - unauthenticated_action - (Optional)
  - default_provider - (Optional)
  - excluded_paths - (Optional)
  - require_https - (Optional) Provider default: true
  - http_route_api_prefix - (Optional) Provider default: `/.auth`
  - forward_proxy_convention - (Optional) Provider default: `NoProxy`
  - forward_proxy_custom_host_header_name - (Optional)
  - forward_proxy_custom_scheme_header_name - (Optional)
  - apple_v2 - (Optional): client_id, client_secret_setting_name, login_scopes
  - active_directory_v2 - (Optional):
    client_id, tenant_auth_endpoint, client_secret_setting_name,
    client_secret_certificate_thumbprint, jwt_allowed_groups,
    jwt_allowed_client_applications, www_authentication_disabled,
    allowed_groups, allowed_identities, allowed_applications,
    login_parameters, allowed_audiences
  - azure_static_web_app_v2 - (Optional): client_id
  - custom_oidc_v2 - (Optional list):
    name, client_id, openid_configuration_endpoint, name_claim_type,
    scopes, client_credential_method, client_secret_setting_name,
    authorisation_endpoint, token_endpoint, issuer_endpoint, certification_uri
  - facebook_v2 - (Optional): app_id, app_secret_setting_name, graph_api_version, login_scopes
  - github_v2 - (Optional): client_id, client_secret_setting_name, login_scopes
  - google_v2 - (Optional): client_id, client_secret_setting_name, allowed_audiences, login_scopes
  - microsoft_v2 - (Optional): client_id, client_secret_setting_name, allowed_audiences, login_scopes
  - twitter_v2 - (Optional): consumer_key, consumer_secret_setting_name
  - login - (Optional in module logic; provider requires when `auth_settings_v2` is used):
    logout_endpoint, token_store_enabled, token_refresh_extension_time,
    token_store_path, token_store_sas_setting_name,
    preserve_url_fragments_for_logins, allowed_external_redirect_urls,
    cookie_expiration_convention, cookie_expiration_time,
    validate_nonce, nonce_expiration_time

  backup block (`settings.backup`):
  - name - (Required when block is used)
  - enabled - (Optional) Provider default: true
  - storage_account_url - (Optional direct value)
  - storage_account - (Optional remote lookup object):
    - key - (Required when lookup is used)
    - lz_key - (Optional)
  - schedule - (Required when block is used):
    - frequency_interval (Required)
    - frequency_unit (Required)
    - keep_at_least_one_backup (Optional, default false)
    - retention_period_days (Optional, default 30)
    - start_time (Optional)

  Other nested blocks:
  - connection_string - (Optional) List of connection string objects:
    - name - (Required)
    - type - (Required; provider enum like `SQLAzure`, `RedisCache`, etc.)
    - value - (Required)
  - identity - (Optional) Managed identity object:
    - type - (Required) `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`.
    - identity_ids - (Optional) Explicit identity ID list.
    - managed_identity_keys - (Optional) Local managed identity keys.
    - remote - (Optional) Map keyed by landing zone; each value includes:
      - managed_identity_keys - (Required when used)
  - storage_account - (Optional) List of storage mount objects:
    - access_key, account_name, name, share_name, type, mount_path
    - key - (Optional) Remote storage account key fallback.
    - lz_key - (Optional) Landing zone key for remote lookup.

  Storage and networking attributes:
  - storage_account_access_key - (Optional) Primary storage access key.
  - storage_account_name - (Optional) Primary storage account name.
  - storage_account_key - (Optional) Remote primary storage lookup object:
    - key - (Required when used)
    - lz_key - (Optional)
  - storage_uses_managed_identity - (Optional) Managed identity storage access toggle.
  - storage_key_vault_secret_id - (Optional) Key Vault secret ID for storage connection.
  - virtual_network_subnet_id - (Optional) Direct subnet ID for regional VNet integration.
  - virtual_network_subnet - (Optional) Remote subnet reference object:
    - vnet_key - (Required when used)
    - subnet_key - (Required when used)
    - lz_key - (Optional)
  - vnet_image_pull_enabled - (Optional) Route image pull traffic over VNet.
  - webdeploy_publish_basic_authentication_enabled - (Optional) WebDeploy basic auth toggle.

  Timeouts:
  - timeouts - (Optional) Operation timeouts:
    - create, read, update, delete
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resource group object."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for dependencies."
  type        = any
}
