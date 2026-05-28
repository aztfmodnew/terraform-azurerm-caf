variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "location" {
  description = "The location of the resource."
  type        = string
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be passed to the module."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings object for this module (resource: azurerm_linux_function_app).

Source of truth: Terraform provider docs for azurerm_linux_function_app (hashicorp/azurerm)
plus this module's helper logic.

Top-level attributes consumed by module logic:
- name
- tags
- enabled
- service_plan_id
- service_plan { key, lz_key }
- service_plan_key
- app_settings
- dynamic_app_settings
- site_config { always_on, api_definition_url, api_management_api_id, api_management_api { key, lz_key }, api_management_api_key, app_command_line, app_scale_limit, application_insights_connection_string, application_insigths_key, application_stack { dotnet_version, use_dotnet_isolated_runtime, java_version, node_version, python_version, powershell_core_version, use_custom_runtime, docker { registry_url, image_name, image_tag, registry_username, registry_password } }, app_service_logs { disk_quota_mb, retention_period_days }, container_registry_managed_identity_client_id, container_registry_use_managed_identity, cors { allowed_origins, support_credentials }, default_documents, elastic_instance_minimum, ftps_state, health_check_path, health_check_eviction_time_in_min, ip_restriction [{ action, ip_address, name, priority, service_tag, virtual_network_subnet_id, description, headers { x_azure_fdid, x_fd_health_probe, x_forwarded_for, x_forwarded_host } }], ip_restriction_default_action, load_balancing_mode, managed_pipeline_mode, minimum_tls_version, pre_warmed_instance_count, remote_debugging_enabled, remote_debugging_version, runtime_scale_monitoring_enabled, scm_ip_restriction [{ action, ip_address, name, priority, service_tag, virtual_network_subnet_id, description, headers { x_azure_fdid, x_fd_health_probe, x_forwarded_for, x_forwarded_host } }], scm_ip_restriction_default_action, scm_minimum_tls_version, scm_use_main_ip_restriction, use_32_bit_worker, vnet_route_all_enabled, websockets_enabled, worker_count }
- auth_settings { enabled, active_directory { client_id, client_secret, allowed_audiences }, additional_login_parameters, allowed_external_redirect_urls, default_provider, facebook { app_id, app_secret, app_secret_setting_name, oauth_scopes }, github { client_id, client_secret, client_secret_setting_name, oauth_scopes }, google { client_id, client_secret, client_secret_setting_name, oauth_scopes }, twitter { consumer_key, consumer_secret }, issuer, microsoft { client_id, client_secret, client_secret_setting_name, oauth_scopes }, runtime_version, token_refresh_extension_hours, token_store_enabled, unauthenticated_client_action }
- auth_settings_v2 { auth_enabled, runtime_version, config_file_path, require_authentication, unauthenticated_action, default_provider, excluded_paths, require_https, http_route_api_prefix, forward_proxy_convention, forward_proxy_custom_host_header_name, forward_proxy_custom_scheme_header_name, apple_v2 { client_id, client_secret_setting_name, login_scopes }, active_directory_v2 { client_id, tenant_auth_endpoint, client_secret_setting_name, client_secret_certificate_thumbprint, jwt_allowed_groups, jwt_allowed_client_applications, www_authentication, allowed_groups, allowed_identities, allowed_applications, login_parameters, allowed_audiences }, azure_static_web_app_v2 { client_id }, custom_oidc_v2 { name, client_id, openid_configuration_endpoint, name_claim_type, scopes, client_credential_method, client_secret_setting_name, authorisation_endpoint, token_endpoint, issuer_endpoint, certification_uri }, facebook_v2 { app_id, app_secret_setting_name, graph_api_version, login_scopes }, github_v2 { client_id, client_secret_setting_name, login_scopes }, google_v2 { client_id, client_secret_setting_name, allowed_audiences, login_scopes }, microsoft_v2 { client_id, client_secret_setting_name, allowed_audiences, login_scopes }, twitter_v2 { consumer_key, consumer_secret_setting_name }, login { logout_endpoint, token_store_enabled, token_refresh_extension_time, token_store_path, token_store_sas_setting_name, preserve_url_fragments_for_logins, allowed_external_redirect_urls, cookie_expiration_convention, cookie_expiration_time, validate_nonce, nonce_expiration_time } }
- backup { name, schedule { frequency_interval, frequency_unit, keep_at_least_one_backup, retention_period_days, start_time }, storage_account_url, storage_account { key, lz_key }, storage_account_key, enabled }
- builtin_logging_enabled
- client_certificate_enabled
- client_certificate_mode
- client_certificate_exclusion_paths
- connection_string { name, type, value }
- daily_memory_time_quota
- content_share_force_disabled
- functions_extension_version
- ftp_publish_basic_authentication_enabled
- https_only
- public_network_access_enabled
- identity { type, managed_identity_keys, remote { managed_identity_keys }, lz_key }
- key_vault_reference_identity_id
- key_vault_reference_identity { key }
- key_vault_reference_identity_key
- storage_account { access_key, lz_key, key, account_name, name, share_name, type, mount_path }
- storage_account_key
- sticky_settings { app_setting_names, connection_string_names }
- storage_account_access_key
- storage_account_name
- storage_uses_managed_identity
- storage_key_vault_secret_id
- virtual_network_subnet_id
- virtual_network_subnet { lz_key, vnet_key, subnet_key }
- vnet_image_pull_enabled
- webdeploy_publish_basic_authentication_enabled
- zip_deploy_file
- timeouts { create, read, update, delete }
- diagnostic_profiles
- linux_function_app_slots

Compatibility notes:
- Current implementation reads compatibility paths under auth_settings.microsoft_v2 and auth_settings.twitter_v2 for some v2 fields.
- Current implementation expects application_insigths_key (spelling preserved for backward compatibility).

Only attributes currently consumed by module logic are documented here.
DESCRIPTION
  type        = any
}

variable "private_endpoints" {
  description = "A map of objects representing the private endpoints to create."
  type        = any
  default     = {}
}