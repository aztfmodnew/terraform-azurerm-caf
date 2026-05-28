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

  This contract documents the keys currently consumed by module code.

  Top-level keys consumed:
  - name
  - tags
  - service_plan_id
  - service_plan_key
  - service_plan.{lz_key,key}
  - app_settings
  - dynamic_app_settings
  - application_insight
  - application_insights.{lz_key,key,instrumentation_key,connection_string}
  - client_affinity_enabled
  - client_certificate_enabled
  - client_certificate_mode
  - client_certificate_exclusion_paths
  - enabled
  - ftp_publish_basic_authentication_enabled
  - https_only
  - public_network_access_enabled
  - key_vault_reference_identity_id
  - key_vault_reference_identity_key
  - key_vault_reference_identity.{lz_key,key}
  - virtual_network_subnet_id
  - virtual_network_subnet.{lz_key,vnet_key,subnet_key}
  - webdeploy_publish_basic_authentication_enabled
  - zip_deploy_file
  - slots (map of slot definitions; each entry is delegated to `./slots` as `settings = each.value`)
  - diagnostic_profiles

  Nested keys consumed:
  - site_config
    - always_on
    - api_definition_url
    - api_management_api_id
    - app_command_line
    - container_registry_managed_identity_client_id
    - container_registry_use_managed_identity
    - default_documents
    - ftps_state
    - health_check_path
    - health_check_eviction_time_in_min
    - http2_enabled
    - ip_restriction_default_action
    - load_balancing_mode
    - local_mysql_enabled
    - managed_pipeline_mode
    - minimum_tls_version
    - remote_debugging_enabled
    - remote_debugging_version
    - scm_ip_restriction_default_action
    - scm_minimum_tls_version
    - scm_use_main_ip_restriction
    - use_32_bit_worker
    - vnet_route_all_enabled
    - websockets_enabled
    - worker_count
    - application_stack.{docker_image_name,docker_registry_url,docker_registry_username,docker_registry_password,dotnet_version,go_version,java_server,java_server_version,java_version,node_version,php_version,python_version,ruby_version}
    - auto_heal_setting.action.{action_type,minimum_process_execution_time}
    - auto_heal_setting.trigger.requests.{count,interval}
    - auto_heal_setting.trigger.slow_request.{count,interval,time_taken}
    - auto_heal_setting.trigger.slow_request_with_path[].{count,interval,time_taken,path}
    - auto_heal_setting.trigger.status_code[].{count,interval,status_code_range,path,sub_status,win32_status_code}
    - cors.{allowed_origins,support_credentials}
    - ip_restriction[].{action,ip_address,name,priority,service_tag,virtual_network_subnet_id,description,headers}
    - ip_restriction[].headers.{x_azure_fdid,x_fd_health_probe,x_forwarded_for,x_forwarded_host}
    - scm_ip_restriction[].{action,ip_address,name,priority,service_tag,virtual_network_subnet_id,description,headers}
    - scm_ip_restriction[].headers.{x_azure_fdid,x_fd_health_probe,x_forwarded_for,x_forwarded_host}

  - auth_settings
    - enabled
    - additional_login_parameters
    - allowed_external_redirect_urls
    - default_provider
    - issuer
    - runtime_version
    - token_refresh_extension_hours
    - token_store_enabled
    - unauthenticated_client_action
    - active_directory.{client_id,allowed_audiences,client_secret,client_secret_setting_name,lz_key,client_id_key,client_secret_key}
    - facebook.{app_id,app_secret,app_secret_setting_name,oauth_scopes}
    - github.{client_id,client_secret,client_secret_setting_name,oauth_scopes}
    - google.{client_id,client_secret,client_secret_setting_name,oauth_scopes}
    - microsoft.{client_id,client_secret,client_secret_setting_name,oauth_scopes}
    - twitter.{consumer_key,consumer_secret,consumer_secret_setting_name}

  - auth_settings_v2
    - auth_enabled
    - runtime_version
    - config_file_path
    - require_authentication
    - unauthenticated_action
    - default_provider
    - excluded_paths
    - require_https
    - http_route_api_prefix
    - forward_proxy_convention
    - forward_proxy_custom_host_header_name
    - forward_proxy_custom_scheme_header_name
    - apple_v2.{client_id,client_secret_setting_name,login_scopes}
    - active_directory_v2.{client_id,tenant_auth_endpoint,client_secret_setting_name,client_secret_certificate_thumbprint,jwt_allowed_groups,jwt_allowed_client_applications,www_authentication_disabled,allowed_groups,allowed_identities,allowed_applications,login_parameters,allowed_audiences}
    - azure_static_web_app_v2.{client_id}
    - custom_oidc_v2[].{name,client_id,openid_configuration_endpoint,name_claim_type,scopes,client_credential_method,client_secret_setting_name,authorisation_endpoint,token_endpoint,issuer_endpoint,certification_uri}
    - facebook_v2.{app_id,app_secret_setting_name,graph_api_version,login_scopes}
    - github_v2.{client_id,client_secret_setting_name,login_scopes}
    - google_v2.{client_id,client_secret_setting_name,allowed_audiences,login_scopes}
    - microsoft_v2.{client_id,client_secret_setting_name,allowed_audiences,login_scopes}
    - twitter_v2.{consumer_key,consumer_secret_setting_name}
    - login.{logout_endpoint,token_store_enabled,token_refresh_extension_time,token_store_path,token_store_sas_setting_name,preserve_url_fragments_for_logins,allowed_external_redirect_urls,cookie_expiration_convention,cookie_expiration_time,validate_nonce,nonce_expiration_time}

  - backup
    - name
    - enabled
    - schedule.{frequency_interval,frequency_unit,keep_at_least_one_backup,retention_period_days,start_time}
    - storage_account_url
    - storage_account_key
    - storage_account.{lz_key,key}
    - lz_key
    - container_key
    - sas_policy.{expire_in_days,rotation}
    - sas_policy.rotation.{mins,days,months,years}

  - connection_strings[]
    - name
    - type
    - value
    - fully_qualified_domain_name
    - mssql_server_key
    - mssql_database_key
    - mssql_database_name
    - server
    - database
    - user
    - password
    - host
    - namespace
    - key_name
    - key_value
    - entity_path
    - endpoint
    - key
    - client_id
    - client_secret

  - identity
    - type
    - managed_identity_keys
    - remote.{lz_key}.managed_identity_keys
    - lz_key

  - logs
    - detailed_error_messages
    - failed_request_tracing
    - lz_key
    - storage_account_key
    - container_key
    - sas_policy.{expire_in_days,rotation}
    - sas_policy.rotation.{mins,days,months,years}
    - application_logs.file_system_level
    - application_logs.azure_blob_storage.{level,retention_in_days,sas_url}
    - http_logs.lz_key
    - http_logs.storage_account_key
    - http_logs.container_key
    - http_logs.sas_policy.{expire_in_days,rotation}
    - http_logs.sas_policy.rotation.{mins,days,months,years}
    - http_logs.azure_blob_storage.{retention_in_days,sas_url}
    - http_logs.file_system.{retention_in_days,retention_in_mb}

  - storage_account
    - access_key
    - account_name
    - name
    - share_name
    - type
    - mount_path
    - lz_key
    - key
    - storage_account_key

  - sticky_settings.{app_setting_names,connection_string_names}
  - timeouts.{create,update,read,delete}

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
