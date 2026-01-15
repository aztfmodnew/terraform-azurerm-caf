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
  Settings object for the Linux Web App Slot (`azurerm_linux_web_app_slot`).
  This contract documents only attributes consumed by this submodule.

  Top-level attributes (`settings.*`):
  - name - (Required) Base slot name consumed by `azurecaf_name`.
  - tags - (Optional) Extra tags merged with module/base tags.

  App settings composition:
  - app_settings - (Optional) Static app settings map merged into final `app_settings`.
  - application_insight - (Optional) App Insights injection object used to compose app settings:
    - instrumentation_key - (Required when `application_insight` is set)
    - connection_string - (Required when `application_insight` is set)
  - dynamic_app_settings - (Optional) Dynamic app settings map resolved from `remote_objects.combined_objects`.
    Shape consumed by locals:
      dynamic_app_settings = {
        "SETTING_NAME" = {
          <resource_type_key> = {
            <object_key> = {
              attribute_key = "<attribute_name>"           # required
              lz_key        = "<landingzone_key>"          # optional (defaults to current landing zone)
            }
          }
        }
      }

  Slot resource arguments:
  - client_affinity_enabled - (Optional)
  - client_certificate_enabled - (Optional)
  - client_certificate_mode - (Optional) Defaults to `Required` in module logic.
  - client_certificate_exclusion_paths - (Optional)
  - enabled - (Optional) Defaults to `true` in module logic.
  - ftp_publish_basic_authentication_enabled - (Optional) Defaults to `true` in module logic.
  - https_only - (Optional) Defaults to `false` in module logic.
  - public_network_access_enabled - (Optional) Defaults to `true` in module logic.
  - key_vault_reference_identity_id - (Optional) Direct user-assigned identity ID for Key Vault references.
  - key_vault_reference_identity_key - (Optional) Fallback identity key used when resolving from `remote_objects.managed_identities`.
  - key_vault_reference_identity - (Optional) Fallback identity lookup object:
    - key - (Optional) Identity key (falls back to `key_vault_reference_identity_key`)
    - lz_key - (Optional) Landing zone key (defaults to current landing zone)
  - virtual_network_subnet_id - (Optional) Direct subnet ID.
  - virtual_network_subnet - (Optional) Subnet lookup object:
    - vnet_key - (Required when block is used)
    - subnet_key - (Required when block is used)
    - lz_key - (Optional) Landing zone key (defaults to current landing zone)
  - webdeploy_publish_basic_authentication_enabled - (Optional) Defaults to `true` in module logic.
  - zip_deploy_file - (Optional)

  `site_config` block (`settings.site_config`) - Optional block with optional attributes consumed:
  - always_on, api_definition_url, api_management_api_id, app_command_line,
    container_registry_managed_identity_client_id, container_registry_use_managed_identity,
    default_documents, ftps_state, health_check_path, health_check_eviction_time_in_min,
    http2_enabled, ip_restriction_default_action, load_balancing_mode, local_mysql_enabled,
    managed_pipeline_mode, minimum_tls_version, remote_debugging_enabled,
    remote_debugging_version, scm_ip_restriction_default_action, scm_minimum_tls_version,
    scm_use_main_ip_restriction, use_32_bit_worker, vnet_route_all_enabled,
    websockets_enabled, worker_count.

  `site_config.application_stack` (Optional object):
  - docker_image_name, docker_registry_url, docker_registry_username, docker_registry_password,
    dotnet_version, go_version, java_server, java_server_version, java_version,
    node_version, php_version, python_version, ruby_version.

  `site_config.auto_heal_setting` (Optional object):
  - action - (Required when block is used):
    - action_type - (Required)
    - minimum_process_execution_time - (Optional)
  - trigger - (Required when block is used):
    - requests (Optional object): count (Required), interval (Required)
    - slow_request (Optional object): count (Required), interval (Required), time_taken (Required)
    - slow_request_with_path (Optional list): count (Required), interval (Required), time_taken (Required), path (Optional)
    - status_code (Optional list): count (Required), interval (Required), status_code_range (Required), path (Optional), sub_status (Optional), win32_status_code (Optional)

  `site_config.cors` (Optional object):
  - allowed_origins - (Optional)
  - support_credentials - (Optional) Defaults to `false` in module logic.

  `site_config.ip_restriction` and `site_config.scm_ip_restriction` (Optional lists):
  - action, ip_address, name, priority, service_tag, virtual_network_subnet_id, description (all Optional)
  - headers (Optional object): x_azure_fdid, x_fd_health_probe, x_forwarded_for, x_forwarded_host (all Optional)

  `auth_settings` block (`settings.auth_settings`) - Optional:
  - enabled, additional_login_parameters, allowed_external_redirect_urls, default_provider,
    issuer, runtime_version, token_refresh_extension_hours, token_store_enabled,
    unauthenticated_client_action (all Optional in module logic)
  - active_directory (Optional object):
    - client_id - (Required when block is used)
    - client_secret, client_secret_setting_name, allowed_audiences - (Optional)
  - facebook (Optional object):
    - app_id - (Required when block is used)
    - app_secret, app_secret_setting_name, oauth_scopes - (Optional)
  - github/google/microsoft (Optional objects):
    - client_id - (Required when block is used)
    - client_secret, client_secret_setting_name, oauth_scopes - (Optional)
  - twitter (Optional object):
    - consumer_key - (Required when block is used)
    - consumer_secret, consumer_secret_setting_name - (Optional)

  `auth_settings_v2` block (`settings.auth_settings_v2`) - Optional:
  - auth_enabled, runtime_version, config_file_path, require_authentication,
    unauthenticated_action, default_provider, excluded_paths, require_https,
    http_route_api_prefix, forward_proxy_convention,
    forward_proxy_custom_host_header_name,
    forward_proxy_custom_scheme_header_name (all Optional in module logic)
  - login (Optional object): logout_endpoint, token_store_enabled, token_refresh_extension_time,
    token_store_path, token_store_sas_setting_name, preserve_url_fragments_for_logins,
    allowed_external_redirect_urls, cookie_expiration_convention,
    cookie_expiration_time, validate_nonce, nonce_expiration_time
  - active_directory_v2 (Optional object):
    - client_id, tenant_auth_endpoint - (Required when block is used)
    - client_secret_setting_name, client_secret_certificate_thumbprint,
      jwt_allowed_groups, jwt_allowed_client_applications,
      www_authentication_disabled, allowed_groups, allowed_identities,
      allowed_applications, login_parameters, allowed_audiences - (Optional)
  - apple_v2 (Optional object): client_id (Required), client_secret_setting_name (Required), login_scopes (Optional)
  - azure_static_web_app_v2 (Optional object): client_id (Required)
  - custom_oidc_v2 (Optional list): name, client_id, openid_configuration_endpoint (Required);
    name_claim_type, scopes, client_credential_method, client_secret_setting_name,
    authorisation_endpoint, token_endpoint, issuer_endpoint, certification_uri (Optional)
  - facebook_v2/github_v2/google_v2/microsoft_v2/twitter_v2 (Optional objects):
    each includes required provider identifier fields and optional scopes/audiences where present in module logic.

  `backup` block (`settings.backup`) - Optional:
  - name - (Required when block is used)
  - enabled - (Optional) Defaults to `true` in module logic.
  - storage_account_url - (Optional) Direct URL/connection string source.
  - storage_account_key - (Optional) Fallback storage account key used in remote lookup.
  - storage_account (Optional object):
    - key - (Optional) Fallback to `storage_account_key`
    - lz_key - (Optional) Landing zone key
  - container_key - (Optional for direct `storage_account_url`; required when SAS URL is resolved from remote storage account)
  - sas_policy (Optional object used by `storage_account.tf` helpers):
    - expire_in_days - (Required when `sas_policy` is set)
    - rotation - (Optional object): mins, days, months, years (all Optional)
  - schedule (Optional object in module logic):
    - frequency_interval, frequency_unit - (Required when `schedule` is set)
    - keep_at_least_one_backup, retention_period_days, start_time - (Optional)

  `connection_strings` (`settings.connection_strings`) - Optional map rendered into `connection_string` blocks:
  - name - (Required per entry)
  - type - (Required per entry)
  - value - (Required per entry)

  `identity` block (`settings.identity`) - Optional:
  - type - (Required when block is used)
  - managed_identity_keys - (Optional) Local managed identity keys.
  - remote - (Optional) Map keyed by landing zone:
    - managed_identity_keys - (Required when remote entry is used)

  `logs` block (`settings.logs`) - Optional:
  - detailed_error_messages, failed_request_tracing - (Optional)
  - storage_account_key - (Optional)
  - container_key - (Optional for direct SAS URLs; required when SAS URL is resolved from remote storage account)
  - lz_key - (Optional) Landing zone key for remote storage lookup.
  - sas_policy (Optional object):
    - expire_in_days - (Required when `sas_policy` is set)
    - rotation - (Optional object): mins, days, months, years (all Optional)
  - application_logs (Optional object):
    - file_system_level - (Optional)
    - azure_blob_storage (Optional object):
      - level, retention_in_days, sas_url - (Optional)
  - http_logs (Optional object):
    - storage_account_key, container_key, lz_key - (Optional for direct `sas_url`; required for remote SAS resolution)
    - sas_policy (Optional object):
      - expire_in_days - (Required when `sas_policy` is set)
      - rotation - (Optional object): mins, days, months, years (all Optional)
    - azure_blob_storage (Optional object): retention_in_days, sas_url (Optional)
    - file_system (Optional object): retention_in_days, retention_in_mb (Optional)

  `storage_account` block (`settings.storage_account`) - Optional list of mount objects:
  - name - (Required per entry)
  - share_name - (Required per entry)
  - type - (Required per entry)
  - mount_path - (Optional)
  - access_key - (Optional direct value)
  - account_name - (Optional direct value)
  - key/storage_account_key - (Optional remote lookup key)
  - lz_key - (Optional landing zone key for remote lookup)

  `timeouts` block (`settings.timeouts`) - Optional:
  - create, read, update, delete - (Optional)

  Notes:
  - `sticky_settings` is not consumed by this submodule.
  - `private_endpoints` is a separate module input variable, not part of `settings`.
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
