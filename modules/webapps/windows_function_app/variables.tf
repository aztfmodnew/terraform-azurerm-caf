## Global settings
variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  
  These are the key naming settings:
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name. Defaults to true.
  DESCRIPTION
  type        = any
}

## Client configuration

variable "client_config" {

  description = <<DESCRIPTION
    Client configuration object primarily used for specifying the Azure client context in non-interactive environments,
    such as CI/CD pipelines running under a Service Principal.

    If this variable is left as an empty map (the default), the module will attempt to derive the client configuration
    (like client_id, tenant_id, subscription_id, object_id) from the current Azure provider context
    (e.g., credentials from Azure CLI, VS Code Azure login, or environment variables).

    If you provide a map, it should contain the necessary authentication and context details. The structure used
    when the default is derived includes keys like:
    - client_id
    - landingzone_key
    - logged_aad_app_objectId
    - logged_user_objectId
    - object_id
    - subscription_id
    - tenant_id

    Example of providing explicit configuration (e.g., for a Service Principal):
    client_config = {
      client_id       = "your-service-principal-client-id"
      object_id       = "your-service-principal-object-id"
      subscription_id = "your-target-subscription-id"
      tenant_id       = "your-azure-ad-tenant-id"
      landingzone_key = "my_landingzone" # Optional, defaults to var.current_landingzone_key if needed elsewhere
      # Add other relevant keys if needed by the specific module context
    }
  DESCRIPTION
  type        = any

}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

# Complete the rest of settings in variable settings
variable "settings" {
  description = <<DESCRIPTION
  Settings object for the Windows Function App (`azurerm_windows_function_app`).
  The attributes below document what this module's logic actually consumes.

  Core attributes:
  - name - (Required) Base name used by `azurecaf_name`.
  - tags - (Optional) Extra tags merged with base tags.
  - diagnostic_profiles - (Optional) Map of diagnostic profile objects consumed by `diagnostics.tf`.
  - slots - (Optional) Map of slot settings passed to the `windows_function_app_slot` submodule.

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

  Service plan resolution:
  - service_plan_id - (Optional) Direct Service Plan resource ID.
  - service_plan - (Optional) Object reference to remote Service Plan:
    - key - (Required when used) Service Plan key.
    - lz_key - (Optional) Landing zone key.
  - service_plan_key - (Optional) Backward-compatible fallback key.

  Resource arguments (top-level):
  - builtin_logging_enabled - (Optional) Built-in logging toggle. Provider default: true.
  - client_certificate_enabled - (Optional) Client certificate requirement toggle.
  - client_certificate_mode - (Optional) One of `Required`, `Optional`, `OptionalInteractiveUser`. Provider default: `Optional`.
  - client_certificate_exclusion_paths - (Optional) `;` separated paths excluded from client-certificate checks.
  - content_share_force_disabled - (Optional) Disable content share settings. Provider default: false.
  - daily_memory_time_quota - (Optional) Daily quota in GB-seconds. Provider default: 0.
  - enabled - (Optional) Function app enabled flag. Provider default: true.
  - ftp_publish_basic_authentication_enabled - (Optional) FTP basic auth publishing profile toggle. Provider default: true.
  - functions_extension_version - (Optional) Runtime version. Provider default: `~4`.
  - https_only - (Optional) HTTPS-only toggle.
  - public_network_access_enabled - (Optional) Public network access toggle. Provider default: true.
  - key_vault_reference_identity_id - (Optional) Direct user-assigned identity ID for Key Vault references.
  - key_vault_reference_identity - (Optional) Remote identity reference:
    - key - (Required when used) Managed identity key.
  - key_vault_reference_identity_key - (Optional) Backward-compatible fallback key.

  site_config block (`settings.site_config`):
  - always_on - (Optional) Always On setting.
  - api_definition_url - (Optional) API definition URL.
  - api_management_api_id - (Optional) Direct APIM API ID.
  - api_management_api / api_management_api_key - (Optional) Remote APIM API reference:
    - api_management_api.key - (Required when used) API key.
    - api_management_api.lz_key - (Optional) Landing zone key.
    - api_management_api_key - (Optional) Backward-compatible fallback key.
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
  - http2_enabled - (Optional) HTTP/2 toggle.
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

  Other nested blocks:
  - connection_string - (Optional) List of connection string objects:
    - name - (Required)
    - type - (Required; provider enum like `SQLAzure`, `RedisCache`, etc.)
    - value - (Required)
  - identity - (Optional) Managed identity object:
    - type - (Required) `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`.
    - managed_identity_keys - (Optional) List of local managed identity keys.
    - remote - (Optional) Map keyed by landing zone; each value includes:
      - managed_identity_keys - (Required when used) List of managed identity keys.
  - storage_account - (Optional) List of storage mount objects:
    - access_key, account_name, name, share_name, type, mount_path
    - key / storage_account_key - (Optional) Remote storage account key fallback.
    - lz_key - (Optional) Landing zone key for remote lookup.

  Storage and networking attributes:
  - storage_account_access_key - (Optional) Primary storage access key.
  - storage_account_name - (Optional) Primary storage account name.
  - storage_uses_managed_identity - (Optional) Managed identity storage access toggle.
  - storage_key_vault_secret_id - (Optional) Key Vault secret ID for storage connection.
  - virtual_network_backup_restore_enabled - (Optional) Backup/restore over VNet toggle.
  - virtual_network_subnet_id - (Optional) Direct subnet ID for regional VNet integration.
  - virtual_network_subnet - (Optional) Remote subnet reference object:
    - vnet_key - (Required when used)
    - subnet_key - (Required when used)
    - lz_key - (Optional)
  - vnet_image_pull_enabled - (Optional) Route image pull traffic over VNet.
  - webdeploy_publish_basic_authentication_enabled - (Optional) WebDeploy basic auth toggle.
  - zip_deploy_file - (Optional) Local zip path for deployment.

  Timeouts:
  - timeouts - (Optional) Operation timeouts:
    - create, read, update, delete

  DESCRIPTION
  type        = any

}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "Flag to determine if tags should be inherited"
}

variable "remote_objects" {
  type        = any
  description = "Remote objects"
}

variable "private_endpoints" {
  description = "A map of objects representing the private endpoints to create."
  type        = any
  default     = {}
}
