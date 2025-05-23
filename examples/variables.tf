variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  These are the settings that can be configured:
  - default_region - (Optional) The default region to use for the global settings object, by default it is set to "region1".
  - environment - (Optional) The environment to use for deployments.
  - inherit_tags - (Optional) A boolean value that indicates whether to inherit tags from the global settings object and from the resource group, by default it is set to false.
  - prefix - (Optional) The prefix to append as the first characters of the generated name. The prefix will be separated by the separator character.
  - suffix - (Optional) The suffix to append after the basename of the resource to create. The suffix will be separated by the separator character.
  - prefix_with_hyphen - (Optional) A boolean value that indicates whether to add a hyphen to the prefix.
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name. The prefixes will be separated by the separator character.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource to create. The suffixes will be separated by the separator character.
  - random_length - (Optional) The length of the random string to generate. Defaults to 0.
  - random_seed - (Optional) The seed to be used for the random generator. 0 will not be respected and will generate a seed based on the Unix time of the generation.
  - resource_type - (Optional) The type of Azure resource you are requesting a name from (e.g., Azure Container Registry: azurerm_container_registry). See the Resource Types supported: https://github.com/aztfmod/terraform-provider-azurecaf?tab=readme-ov-file#resource-status.
  - resource_types - (Optional) A list of additional resource types should you want to use the same settings for a set of resources.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - passthrough - (Optional) A boolean value that indicates whether to pass through the naming convention. In that case only the clean input option is considered and the prefixes, suffixes, random, and are ignored. The resource prefixe is not added either to the resulting string. Defaults to false.
  - regions - (Optional) A map of regions to use for the global settings object.
    - region1 - The name of the first region.
    - region2 - The name of the second region.
    - regionN - The name of the Nth region.
  - tags - (Optional) A map of tags to be inherited from the global settings object if inherit_tags is set to true.
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name, suffix, or prefix. Defaults to true.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
DESCRIPTION
  type        = any
  /*type = object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(bool)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number)
    random_seed        = optional(number)
    resource_type      = optional(string)
    resource_types     = optional(list(string))
    separator          = optional(string)
    clean_input        = optional(bool)
    passthrough        = optional(bool)
    regions            = map(string)
    use_slug           = optional(bool)
  })*/
  default = {
    default_region = "region1"
    inherit_tags   = true
    passthrough    = false
    regions = {
      region1 = "eastus2"
      region2 = "centralus"
    }
  }
}

variable "landingzone" {
  description = <<DESCRIPTION
  The landingzone object is a map of landing zone objects. Each landing zone object has the following keys
- backend_type: The type of backend to use for the landing zone object. Possible values are azurerm, s3, gcs, local and remote.
- global_settings_key: The key of the global settings object to use for the landing zone object.
- level: The level of the landing zone object. Possible values are level0, level1, level2 and level3.
- key: The key of the landing zone object.
DESCRIPTION

  type = any
  default = {
    backend_type        = "azurerm"
    global_settings_key = "launchpad"
    level               = "level0"
    key                 = "examples"
  }
}

variable "var_folder_path" {
  description = "The path to the folder containing the variables files"
  type        = string
  default     = ""
}

# variable "cloud" {
#   default = {}
# }
# variable "acrLoginServerEndpoint" {
#   default = ".azurecr.io"
# }
# variable "attestationEndpoint" {
#   default = ".attest.azure.net"
# }
# variable "azureDatalakeAnalyticsCatalogAndJobEndpoint" {
#   default = "azuredatalakeanalytics.net"
# }
# variable "azureDatalakeStoreFileSystemEndpoint" {
#   default = "azuredatalakestore.net"
# }
# variable "keyvaultDns" {
#   default = ".vault.azure.net"
# }
# variable "mhsmDns" {
#   default = ".managedhsm.azure.net"
# }
# variable "mysqlServerEndpoint" {
#   default = ".mysql.database.azure.com"
# }
# variable "postgresqlServerEndpoint" {
#   default = ".postgres.database.azure.com"
# }
# variable "sqlServerHostname" {
#   default = ".database.windows.net"
# }
# variable "storageEndpoint" {
#   default = "core.windows.net"
# }
# variable "storageSyncEndpoint" {
#   default = "afs.azure.net"
# }
# variable "synapseAnalyticsEndpoint" {
#   default = ".dev.azuresynapse.net"
# }
# variable "activeDirectory" {
#   default = "https://login.microsoftonline.com"
# }
# variable "activeDirectoryDataLakeResourceId" {
#   default = "https://datalake.azure.net/"
# }
# variable "activeDirectoryGraphResourceId" {
#   default = "https://graph.windows.net/"
# }
# variable "activeDirectoryResourceId" {
#   default = "https://management.core.windows.net/"
# }
# variable "appInsightsResourceId" {
#   default = "https://api.applicationinsights.io"
# }
# variable "appInsightsTelemetryChannelResourceId" {
#   default = "https://dc.applicationinsights.azure.com/v2/track"
# }
# variable "attestationResourceId" {
#   default = "https://attest.azure.net"
# }
# variable "azmirrorStorageAccountResourceId" {
#   default = "null"
# }
# variable "batchResourceId" {
#   default = "https://batch.core.windows.net/"
# }
# variable "gallery" {
#   default = "https://gallery.azure.com/"
# }
# variable "logAnalyticsResourceId" {
#   default = "https://api.loganalytics.io"
# }
# variable "management" {
#   default = "https://management.core.windows.net/"
# }
# variable "mediaResourceId" {
#   default = "https://rest.media.azure.net"
# }
# variable "microsoftGraphResourceId" {
#   default = "https://graph.microsoft.com/"
# }
# variable "ossrdbmsResourceId" {
#   default = "https://ossrdbms-aad.database.windows.net"
# }
# variable "portal" {
#   default = "https://portal.azure.com"
# }
# variable "resourceManager" {
#   default = "https://management.azure.com/"
# }
# variable "sqlManagement" {
#   default = "https://management.core.windows.net:8443/"
# }
# variable "synapseAnalyticsResourceId" {
#   default = "https://dev.azuresynapse.net"
# }
# variable "vmImageAliasDoc" {
#   default = "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json"
# }
variable "environment" {
  description = "The environment in which the resources are deployed."
  default     = "sandpit"
  type        = string
}
variable "rover_version" {
  default = null
  type    = string
}
variable "logged_user_objectId" {
  default = null
  type    = string
}
variable "logged_aad_app_objectId" {
  default = null
  type    = string
}
variable "tags" {
  default = null
  type    = map(any)
}
variable "subscription_billing_role_assignments" {
  type    = any
  default = {}
}
variable "ai_services" {
  type    = any
  default = {}
}

variable "app_service_environments" {
  type    = any
  default = {}
}
variable "app_service_environments_v3" {
  type    = any
  default = {}
}
variable "app_service_plans" {
  type    = any
  default = {}
}
variable "app_services" {
  type    = any
  default = {}
}
variable "consumption_budgets" {
  type    = any
  default = {}
}
variable "diagnostics_definition" {
  type    = any
  default = {}
}
variable "resource_groups" {
  type    = any
  default = {}
}

variable "network_managers" {
  default = {}
  type    = any
}

variable "network_manager_admin_rules" {
  default = {}
  type    = any
}

variable "network_manager_admin_rule_collections" {
  default = {}
  type    = any
}

variable "network_manager_connectivity_configurations" {
  default = {}
  type    = any
}

variable "network_manager_deployments" {
  default = {}
  type    = any
}

variable "network_manager_network_groups" {
  default = {}
  type    = any
}

variable "network_manager_management_group_connections" {
  default = {}
  type    = any
}

variable "network_manager_security_admin_configurations" {
  default = {}
  type    = any
}

variable "network_manager_scope_connections" {
  default = {}
  type    = any
}

variable "network_manager_static_members" {
  default = {}
  type    = any
}

variable "network_manager_subscription_connections" {
  default = {}
  type    = any
}

variable "network_security_group_definition" {
  default = {}
  type    = any
}
variable "network_security_perimeters" {
  default = {}
  type    = any
}

variable "network_security_security_rules" {
  type    = any
  default = {}
}
variable "route_tables" {
  type    = any
  default = {}
}
variable "azurerm_routes" {
  type    = any
  default = {}
}
variable "vnets" {
  type    = any
  default = {}
}
variable "virtual_subnets" {
  type    = any
  default = {}
}
variable "azurerm_redis_caches" {
  type    = any
  default = {}
}
variable "mssql_servers" {
  type    = any
  default = {}
}
variable "mssql_managed_instances" {
  type    = any
  default = {}
}
variable "mssql_managed_instances_secondary" {
  type    = any
  default = {}
}
variable "mssql_databases" {
  type    = any
  default = {}
}
variable "mssql_managed_databases" {
  type    = any
  default = {}
}
variable "mssql_managed_databases_restore" {
  type    = any
  default = {}
}
variable "mssql_managed_databases_backup_ltr" {
  type    = any
  default = {}
}
variable "mssql_elastic_pools" {
  type    = any
  default = {}
}
variable "mssql_failover_groups" {
  type    = any
  default = {}
}
variable "mssql_mi_failover_groups" {
  type    = any
  default = {}
}
variable "mssql_mi_administrators" {
  type    = any
  default = {}
}
variable "mssql_mi_tdes" {
  type    = any
  default = {}
}
variable "mssql_mi_secondary_tdes" {
  type    = any
  default = {}
}
variable "storage_accounts" {
  type    = any
  default = {}
}
variable "storage_account_file_shares" {
  type    = any
  default = {}
}
variable "maps_accounts" {
  type    = any
  default = {}
}
variable "azuread_credential_policies" {
  type    = any
  default = {}
}
variable "azuread_applications" {
  type    = any
  default = {}
}
variable "azuread_credentials" {
  type    = any
  default = {}
}
variable "azuread_groups_membership" {
  type    = any
  default = {}
}
variable "azuread_service_principals" {
  type    = any
  default = {}
}
variable "azuread_service_principal_passwords" {
  type    = any
  default = {}
}
variable "azuread_groups" {
  type    = any
  default = {}
}
variable "azuread_roles" {
  type    = any
  default = {}
}
variable "azuread_administrative_units" {
  type    = any
  default = {}
}
variable "azuread_administrative_unit_members" {
  type    = any
  default = {}
}
variable "keyvaults" {
  type    = any
  default = {}
}
variable "keyvault_access_policies" {
  type    = any
  default = {}
}
variable "keyvault_certificate_issuers" {
  type    = any
  default = {}
}
variable "keyvault_keys" {
  type    = any
  default = {}
}
variable "keyvault_certificate_requests" {
  type    = any
  default = {}
}
variable "keyvault_certificates" {
  type    = any
  default = {}
}
variable "virtual_machines" {
  type    = any
  default = {}
}
variable "virtual_machine_scale_sets" {
  type    = any
  default = {}
}
variable "ddos_services" {
  type    = any
  default = {}
}
variable "bastion_hosts" {
  type    = any
  default = {}
}
variable "public_ip_addresses" {
  type    = any
  default = {}
}
variable "diagnostic_storage_accounts" {
  type    = any
  default = {}
}
variable "diagnostic_event_hub_namespaces" {
  type    = any
  default = {}
}
variable "diagnostic_log_analytics" {
  type    = any
  default = {}
}
variable "managed_identities" {
  type    = any
  default = {}
}
variable "private_dns" {
  type    = any
  default = {}
}
variable "synapse_workspaces" {
  type    = any
  default = {}
}
variable "azurerm_application_insights" {
  type    = any
  default = {}
}
variable "azurerm_application_insights_web_test" {
  type    = any
  default = {}
}
variable "azurerm_application_insights_standard_web_test" {
  type    = any
  default = {}
}
variable "role_mapping" {
  type    = any
  default = {}
}
variable "aks_clusters" {
  type    = any
  default = {}
}
variable "azure_container_registries" {
  type    = any
  default = {}
}
variable "batch_accounts" {
  type    = any
  default = {}
}
variable "batch_applications" {
  type    = any
  default = {}
}
variable "batch_certificates" {
  type    = any
  default = {}
}
variable "batch_jobs" {
  type    = any
  default = {}
}
variable "batch_pools" {
  type    = any
  default = {}
}
variable "databricks_workspaces" {
  type    = any
  default = {}
}
variable "databricks_access_connectors" {
  type    = any
  default = {}
}
variable "machine_learning_workspaces" {
  type    = any
  default = {}
}
variable "monitor_action_groups" {
  type    = any
  default = {}
}
variable "monitor_autoscale_settings" {
  type    = any
  default = {}
}
variable "monitoring" {
  type    = any
  default = {}
}
variable "virtual_hubs" {
  type    = any
  default = {}
}
variable "virtual_wans" {
  type    = any
  default = {}
}
variable "event_hub_namespaces" {
  type    = any
  default = {}
}
variable "application_gateways" {
  type    = any
  default = {}
}
variable "application_gateway_platforms" {
  type    = any
  default = {}
}
variable "application_gateway_applications" {
  type    = any
  default = {}
}
variable "application_gateway_applications_v1" {
  type    = any
  default = {}
}
variable "application_gateway_waf_policies" {
  type    = any
  default = {}
}
variable "postgresql_flexible_servers" {
  type    = any
  default = {}
}
variable "postgresql_servers" {
  type    = any
  default = {}
}
variable "log_analytics" {
  type    = any
  default = {}
}
variable "logic_app_workflow" {
  type    = any
  default = {}
}
variable "logic_app_standard" {
  type    = any
  default = {}
}
variable "logic_app_integration_account" {
  type    = any
  default = {}
}
variable "recovery_vaults" {
  type    = any
  default = {}
}
variable "availability_sets" {
  type    = any
  default = {}
}
variable "proximity_placement_groups" {
  type    = any
  default = {}
}
variable "network_watchers" {
  type    = any
  default = {}
}
variable "virtual_network_gateways" {
  type    = any
  default = {}
}
variable "virtual_network_gateway_connections" {
  type    = any
  default = {}
}
variable "express_route_circuits" {
  type    = any
  default = {}
}
variable "express_route_circuit_authorizations" {
  type    = any
  default = {}
}

variable "shared_image_galleries" {
  type    = any
  default = {}
}

variable "image_definitions" {
  type    = any
  default = {}
}

variable "diagnostics_destinations" {
  type    = any
  default = {}
}
variable "vnet_peerings" {
  type    = any
  default = {}
}
variable "vnet_peerings_v1" {
  type    = any
  default = {}
}

variable "packer_service_principal" {
  type    = any
  default = {}
}

variable "packer_build" {
  type    = any
  default = {}
}

variable "azuread_api_permissions" {
  type    = any
  default = {}
}

variable "keyvault_access_policies_azuread_apps" {
  type    = any
  default = {}
}

variable "cosmos_dbs" {
  type    = any
  default = {}
}
variable "dynamic_keyvault_secrets" {
  type    = any
  default = {}
}
variable "dynamic_keyvault_certificates" {
  type    = any
  default = {}
}
variable "front_doors" {
  type    = any
  default = {}
}
variable "front_door_waf_policies" {
  type    = any
  default = {}
}
variable "dns_zones" {
  type    = any
  default = {}
}
variable "dns_zone_records" {
  type    = any
  default = {}
}

variable "private_endpoints" {
  type    = any
  default = {}
}

variable "event_hubs" {
  type    = any
  default = {}
}
variable "automations" {
  type    = any
  default = {}
}
variable "automation_schedules" {
  type    = any
  default = {}
}
variable "automation_runbooks" {
  type    = any
  default = {}
}
variable "automation_log_analytics_links" {
  type    = any
  default = {}
}

variable "local_network_gateways" {
  type    = any
  default = {}
}

variable "domain_name_registrations" {
  type    = any
  default = {}
}

variable "azuread_apps" {
  default = {}
  type    = map(any)
}
variable "azuread_users" {
  default = {}
  type    = map(any)
}
variable "custom_role_definitions" {
  type    = any
  default = {}
}
variable "azurerm_firewalls" {
  type    = any
  default = {}
}
variable "azurerm_firewall_network_rule_collection_definition" {
  type    = any
  default = {}
}
variable "azurerm_firewall_application_rule_collection_definition" {
  type    = any
  default = {}
}
variable "azurerm_firewall_nat_rule_collection_definition" {
  type    = any
  default = {}
}
variable "event_hub_auth_rules" {
  type    = any
  default = {}
}

variable "netapp_accounts" {
  type    = any
  default = {}
}

variable "load_balancers" {
  type    = any
  default = {}
}

variable "ip_groups" {
  type    = any
  default = {}
}
variable "container_app_environments" {
  type    = any
  default = {}
}
variable "container_app_environment_certificates" {
  type    = any
  default = {}
}
variable "container_app_dapr_components" {
  type    = any
  default = {}
}
variable "container_apps" {
  type    = any
  default = {}
}
variable "container_app_environment_storages" {
  type    = any
  default = {}
}
variable "container_groups" {
  type    = any
  default = {}
}
variable "event_hub_namespace_auth_rules" {
  type    = any
  default = {}
}
variable "event_hub_consumer_groups" {
  type    = any
  default = {}
}
variable "application_security_groups" {
  type    = any
  default = {}
}

variable "azurerm_firewall_policies" {
  type    = any
  default = {}
}

variable "azurerm_firewall_policy_rule_collection_groups" {
  type    = any
  default = {}
}
variable "disk_encryption_sets" {
  type    = any
  default = {}
}
variable "vhub_peerings" {
  description = "Use virtual_hub_connections instead of vhub_peerings. It will be removed in version 6.0"
  type        = any
  default     = {}
}
variable "virtual_hub_connections" {
  type    = any
  default = {}
}
variable "virtual_hub_route_table_routes" {
  type    = any
  default = {}
}
variable "virtual_hub_route_tables" {
  type    = any
  default = {}
}
variable "virtual_hub_er_gateway_connections" {
  type    = any
  default = {}
}
variable "wvd_application_groups" {
  type    = any
  default = {}
}
variable "wvd_workspaces" {
  type    = any
  default = {}
}
variable "wvd_host_pools" {
  type    = any
  default = {}
}
variable "wvd_applications" {
  type    = any
  default = {}
}
variable "lighthouse_definitions" {
  type    = any
  default = {}
}
variable "linux_function_apps" {
  type    = any
  default = {}
}
variable "dedicated_host_groups" {
  type    = any
  default = {}
}
variable "dedicated_hosts" {
  type    = any
  default = {}
}
variable "vpn_sites" {
  type    = any
  default = {}
}
variable "palo_alto_cloudngfws" {
  type    = any
  default = {}
}

variable "vpn_gateway_connections" {
  type    = any
  default = {}
}
variable "vpn_gateway_nat_rules" {
  type    = any
  default = {}
}
variable "service_plans" {
  description = <<DESCRIPTION
The service_plans object is a map of service plan objects. Each service plan object has the following keys:
- resource_group_key: The key of the resource group object to deploy the Azure resource.
- name: (Required) The name of the service plan.
- location: The location of the service plan. If not provided, the location of the resource group will be used.
- os_type: (Required) The operating system of the service plan. Possible values are Windows, Linux and WindowsContainer.
- sku_name: (Required) The SKU name of the service plan.
- app_service_environment_id: (Optional) The ID of the App Service Environment where the service plan should be created.
- app_service_environment: (Optional) The App Service Environment object where the service plan should be created.
  - lz_key: The key of the landing zone object to deploy the Azure resource.
  - key: The key of the App Service Environment object to deploy the Azure resource.
- app_service_environment_v3: (Optional) The App Service Environment V3 object where the service plan should be created.
  - lz_key: The key of the landing zone object to deploy the Azure resource.
  - key: The key of the App Service Environment V3 object to deploy the Azure resource.
- maximum_elastic_worker_count: (Optional) The maximum number of workers that can be allocated to this App Service Plan.
- worker_count: (Optional) The number of workers to allocate.
- per_site_scaling_enabled: (Optional) Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.
- tags: (Optional) The tags for the service plan.

Example:

service_plans = {
  sp1 = {
    resource_group_key = "test_re1"
    name               = "asp-simple"
    os_type            = "Linux"
    sku_name           = "FC1"

    tags = {
      project = "Test"
    }
  }
}
DESCRIPTION
  default     = {}
  type        = any
}


variable "servicebus_namespaces" {
  default = {}
  type    = any
}
variable "servicebus_topics" {
  type    = any
  default = {}
}
variable "servicebus_queues" {
  type    = any
  default = {}
}
variable "storage_account_queues" {
  type    = any
  default = {}
}
variable "storage_account_blobs" {
  type    = any
  default = {}
}
variable "storage_containers" {
  type    = any
  default = {}
}
variable "vmware_private_clouds" {
  type    = any
  default = {}
}
variable "vmware_clusters" {
  type    = any
  default = {}
}
variable "vmware_express_route_authorizations" {
  type    = any
  default = {}
}
variable "nat_gateways" {
  type    = any
  default = {}
}
variable "cognitive_services_account" {
  type    = any
  default = {}
}
variable "cognitive_account_customer_managed_key" {
  type    = any
  default = {}
}
variable "cognitive_deployment" {
  type    = any
  default = {}
}

variable "database_migration_services" {
  type    = any
  default = {}
}
variable "database_migration_projects" {
  type    = any
  default = {}
}
variable "data_factory" {
  type    = any
  default = {}
}
variable "data_factory_pipeline" {
  type    = any
  default = {}
}
variable "data_factory_trigger_schedule" {
  type    = any
  default = {}
}
variable "data_factory_dataset_azure_blob" {
  type    = any
  default = {}
}
variable "data_factory_dataset_cosmosdb_sqlapi" {
  type    = any
  default = {}
}
variable "data_factory_dataset_delimited_text" {
  type    = any
  default = {}
}
variable "data_factory_dataset_http" {
  type    = any
  default = {}
}
variable "data_factory_dataset_json" {
  type    = any
  default = {}
}
variable "data_factory_dataset_mysql" {
  type    = any
  default = {}
}
variable "data_factory_dataset_postgresql" {
  type    = any
  default = {}
}
variable "data_factory_dataset_sql_server_table" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_azure_blob_storage" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_cosmosdb" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_web" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_mysql" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_postgresql" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_sql_server" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_azure_databricks" {
  type    = any
  default = {}
}
variable "integration_service_environment" {
  type    = any
  default = {}
}
variable "logic_app_action_http" {
  type    = any
  default = {}
}
variable "logic_app_action_custom" {
  type    = any
  default = {}
}
variable "logic_app_trigger_http_request" {
  type    = any
  default = {}
}
variable "logic_app_trigger_recurrence" {
  type    = any
  default = {}
}
variable "logic_app_trigger_custom" {
  type    = any
  default = {}
}
variable "kusto_clusters" {
  type    = any
  default = {}
}
variable "kusto_databases" {
  type    = any
  default = {}
}
variable "kusto_attached_database_configurations" {
  type    = any
  default = {}
}
variable "kusto_cluster_customer_managed_keys" {
  type    = any
  default = {}
}
variable "kusto_cluster_principal_assignments" {
  type    = any
  default = {}
}
variable "kusto_database_principal_assignments" {
  type    = any
  default = {}
}
variable "kusto_eventgrid_data_connections" {
  type    = any
  default = {}
}
variable "kusto_eventhub_data_connections" {
  type    = any
  default = {}
}
variable "kusto_iothub_data_connections" {
  type    = any
  default = {}
}
variable "private_dns_vnet_links" {
  type    = any
  default = {}
}
variable "communication_services" {
  type    = any
  default = {}
}
variable "machine_learning_compute_instance" {
  type    = any
  default = {}
}
variable "data_factory_integration_runtime_self_hosted" {
  type    = any
  default = {}
}
variable "data_factory_integration_runtime_azure_ssis" {
  type    = any
  default = {}
}
variable "frontdoor_rules_engine" {
  type    = any
  default = {}
}
variable "frontdoor_custom_https_configuration" {
  type    = any
  default = {}
}
variable "cdn_endpoint" {
  type    = any
  default = {}
}
variable "cdn_profile" {
  type    = any
  default = {}
}
variable "function_apps" {
  type    = any
  default = {}
}
variable "active_directory_domain_service" {
  type    = any
  default = {}
}
variable "active_directory_domain_service_replica_set" {
  type    = any
  default = {}
}
variable "mysql_flexible_server" {
  type    = any
  default = {}
}

variable "signalr_services" {
  type    = any
  default = {}
}
variable "api_management" {
  type    = any
  default = {}
}
variable "api_management_api" {
  type    = any
  default = {}
}
variable "api_management_api_diagnostic" {
  type    = any
  default = {}

}
variable "api_management_logger" {
  type    = any
  default = {}
}
variable "api_management_api_operation" {
  type    = any
  default = {}
}
variable "api_management_backend" {
  type    = any
  default = {}
}
variable "api_management_api_policy" {
  type    = any
  default = {}
}
variable "api_management_api_operation_policy" {
  type    = any
  default = {}
}
variable "api_management_api_operation_tag" {
  type    = any
  default = {}
}
variable "api_management_user" {
  type    = any
  default = {}
}
variable "api_management_custom_domain" {
  type    = any
  default = {}
}
variable "api_management_diagnostic" {
  type    = any
  default = {}
}
variable "api_management_certificate" {
  type    = any
  default = {}
}
variable "api_management_gateway" {
  type    = any
  default = {}
}
variable "api_management_gateway_api" {
  type    = any
  default = {}
}
variable "api_management_group" {
  type    = any
  default = {}
}
variable "api_management_subscription" {
  type    = any
  default = {}
}
variable "api_management_product" {
  type    = any
  default = {}
}
variable "lb" {
  type    = any
  default = {}
}
variable "lb_backend_address_pool" {
  type    = any
  default = {}
}
variable "lb_backend_address_pool_address" {
  type    = any
  default = {}
}
variable "lb_nat_pool" {
  type    = any
  default = {}
}
variable "lb_nat_rule" {
  type    = any
  default = {}
}
variable "lb_outbound_rule" {
  type    = any
  default = {}
}
variable "lb_probe" {
  type    = any
  default = {}
}
variable "lb_rule" {
  type    = any
  default = {}
}
variable "network_interface_backend_address_pool_association" {
  type    = any
  default = {}
}
variable "digital_twins_instances" {
  description = "Digital Twins Instances"
  type        = any
  default     = {}
}

variable "digital_twins_endpoint_eventhubs" {
  description = "Digital Twins Endpoints Eventhubs"
  type        = any
  default     = {}
}

variable "digital_twins_endpoint_eventgrids" {
  description = "Digital Twins Endpoints Eventgrid"
  type        = any
  default     = {}
}

variable "digital_twins_endpoint_servicebuses" {
  description = "Digital Twins Endpoints Service Bus"
  type        = any
  default     = {}
}

variable "monitor_metric_alert" {
  type    = any
  default = {}
}
variable "monitor_activity_log_alert" {
  type    = any
  default = {}
}
variable "log_analytics_storage_insights" {
  type    = any
  default = {}
}
variable "eventgrid_domain" {
  type    = any
  default = {}
}
variable "eventgrid_topic" {
  type    = any
  default = {}
}
variable "eventgrid_event_subscription" {
  type    = any
  default = {}
}
variable "eventgrid_domain_topic" {
  type    = any
  default = {}
}
variable "relay_hybrid_connection" {
  type    = any
  default = {}
}
variable "relay_namespace" {
  type    = any
  default = {}
}
variable "purview_accounts" {
  type    = any
  default = {}
}
variable "app_config" {
  type    = any
  default = {}
}
variable "cosmosdb_sql_databases" {
  type    = any
  default = {}
}
variable "sentinel" {
  type    = any
  default = {}
}
variable "sentinel_automation_rules" {
  type    = any
  default = {}
}
variable "sentinel_watchlists" {
  type    = any
  default = {}
}
variable "sentinel_watchlist_items" {
  type    = any
  default = {}
}
variable "sentinel_ar_fusions" {
  type    = any
  default = {}
}
variable "sentinel_ar_ml_behavior_analytics" {
  type    = any
  default = {}
}
variable "sentinel_ar_ms_security_incidents" {
  type    = any
  default = {}
}
variable "sentinel_ar_scheduled" {
  type    = any
  default = {}
}
variable "sentinel_dc_aad" {
  type    = any
  default = {}
}
variable "sentinel_dc_app_security" {
  type    = any
  default = {}
}
variable "sentinel_dc_aws" {
  type    = any
  default = {}
}
variable "sentinel_dc_azure_threat_protection" {
  type    = any
  default = {}
}
variable "sentinel_dc_ms_threat_protection" {
  type    = any
  default = {}
}
variable "sentinel_dc_office_365" {
  type    = any
  default = {}
}
variable "sentinel_dc_security_center" {
  type    = any
  default = {}
}
variable "sentinel_dc_threat_intelligence" {
  type    = any
  default = {}
}
variable "public_ip_prefixes" {
  type    = any
  default = {}
}
variable "runbooks" {
  type    = any
  default = {}
}
variable "backup_vaults" {
  type    = any
  default = {}
}
variable "backup_vault_policies" {
  type    = any
  default = {}
}
variable "backup_vault_instances" {
  type    = any
  default = {}
}
variable "traffic_manager_azure_endpoint" {
  type    = any
  default = {}
}
variable "traffic_manager_external_endpoint" {
  type    = any
  default = {}
}
variable "traffic_manager_nested_endpoint" {
  type    = any
  default = {}
}
variable "traffic_manager_profile" {
  type    = any
  default = {}
}
variable "resource_provider_registration" {
  type    = any
  default = {}
}
variable "static_sites" {
  type    = any
  default = {}
}
variable "aro_clusters" {
  type    = any
  default = {}
}
variable "windows_web_apps" {
  description = <<DESCRIPTION
  The windows_web_appss object is a map of windows web app objects. Each windows web app object has the following keys:
- resource_group_key: The key of the resource group object to deploy the Azure resource.
- name: (Required) The name of the windows web app.
- service_plan_key: (Required) The key of the service plan object to deploy the Azure resource.
- location: The location of the windows web app. If not provided, the location of the resource group will be used.
- settings: (Optional) The settings for the windows web app.
- app_settings: (Optional) The app settings for the windows web app.
- connection_string: (Optional) The connection string for the windows web app.
- identity: (Optional) The identity for the windows web app.
- identity_type: (Optional) The identity type for the windows web app. Possible values are SystemAssigned, UserAssigned and None.
- identity_ids: (Optional) The identity IDs for the windows web app.
- https_only: (Optional) Should the windows web app enforce HTTPS only. Changing this forces a new resource to be created.
- client_cert_enabled: (Optional) Should the windows web app require client certificates. Changing this forces a new resource to be created.
- client_cert_mode: (Optional) The client certificate mode for the windows web app. Possible values are Require and Allow.

  
  

  DESCRIPTION
  type        = any
  default     = {}
}
variable "web_pubsubs" {
  description = "Configuration settings for Azure Web PubSub services."
  type        = any
  default     = {}
}
variable "web_pubsub_hubs" {
  type    = any
  default = {}
}
variable "aadb2c_directory" {
  description = <<DESCRIPTION
  The aadb2c_directory object is a map of AAD B2C directory objects. Each AAD B2C directory object has the following keys:
    - country_code - (Optional) The country code for the AAD B2C directory. This is optional and can be set to null.
    - data_residency_location - (Required) The data residency location for the AAD B2C directory. This is required and cannot be null.
    - display_name - (Optional) The display name for the AAD B2C directory. This is optional and can be set to null.
    - domain_name - (Required) The domain name for the AAD B2C directory. This is required and cannot be null.
    - sku_name - (Required) The SKU name for the AAD B2C directory. This is required and cannot be null.
    - tags - (Optional) A mapping of tags which should be assigned to the AAD B2C Directory.
    - resource_group_name - (Required if resource_group_key and resource_group is not set) The name of the resource group in which the AAD B2C directory will be created. This is required and cannot be null.
    - resource_group_key - (Optional) The key of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
    - resource_group - (Optional) The resource group object in which the AAD B2C directory will be created. This is optional and can be set to null.
      - lz_key - (Optional) The key of the landing zone in which the AAD B2C directory will be created. This is optional and can be set to null.
      - key - (Optional) The key of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
      - name - (Optional) The name of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
  DESCRIPTION
  default     = {} # Make the variable nullable by default
  type = map(object({
    country_code            = optional(string)
    data_residency_location = string # Required if object is provided
    display_name            = optional(string)
    domain_name             = string # Required if object is provided
    resource_group_name     = optional(string)
    sku_name                = string # Required if object is provided
    tags                    = optional(map(string))
    resource_group_key      = optional(string)
    resource_group = optional(object({
      lz_key = optional(string)
      key    = optional(string)
      name   = optional(string)
    }))
  }))
  sensitive = false
  validation {
    # Check if aadb2c_directory is {} OR if all keys within each directory object are valid.
    condition = var.aadb2c_directory == {} || alltrue([
      for dir_key, dir_value in var.aadb2c_directory :
      length(setsubtract(keys(dir_value), [
        "country_code",
        "data_residency_location",
        "display_name",
        "domain_name",
        "resource_group_name",
        "sku_name",
        "tags",
        "resource_group_key",
        "resource_group"
      ])) == 0
    ])
    error_message = "One or more entries in aadb2c_directory contain unsupported attributes. Allowed attributes are: country_code, data_residency_location, display_name, domain_name, resource_group_name, sku_name, tags, resource_group_key, resource_group."
  }
}
variable "powerbi_embedded" {
  type    = any
  default = {}
}
variable "preview_features" {
  type    = any
  default = {}
}
variable "private_dns_resolvers" {
  type    = any
  default = {}
}
variable "private_dns_resolver_inbound_endpoints" {
  type    = any
  default = {}
}
variable "private_dns_resolver_outbound_endpoints" {
  type    = any
  default = {}
}
variable "private_dns_resolver_dns_forwarding_rulesets" {
  type    = any
  default = {}
}

variable "private_dns_resolver_forwarding_rules" {
  type    = any
  default = {}
}

variable "private_dns_resolver_virtual_network_links" {
  type    = any
  default = {}
}

variable "iot_security_solution" {
  type    = any
  default = {}
}
variable "iot_security_device_group" {
  type    = any
  default = {}
}
variable "iot_central_application" {
  type    = any
  default = {}
}
variable "iot_hub" {
  type    = any
  default = {}
}
variable "iot_hub_dps" {
  type    = any
  default = {}
}
variable "iot_hub_shared_access_policy" {
  type    = any
  default = {}
}
variable "iot_dps_certificate" {
  type    = any
  default = {}
}
variable "iot_dps_shared_access_policy" {
  type    = any
  default = {}
}
variable "iot_hub_consumer_groups" {
  type    = any
  default = {}
}
variable "iot_hub_certificate" {
  type    = any
  default = {}
}
variable "cosmosdb_role_mapping" {
  type    = any
  default = {}
}
variable "cosmosdb_role_definitions" {
  type    = any
  default = {}
}
variable "data_sources" {
  type    = any
  default = {}
}
variable "maintenance_configuration" {
  type    = any
  default = {}
}
variable "maintenance_assignment_virtual_machine" {
  type    = any
  default = {}
}
variable "search_services" {
  type    = any
  default = {}
}
variable "load_test" {
  default = {}
  type    = any
}