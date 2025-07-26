variable "resource_type" {
  description = "The type of Azure resource for which to generate a name"
  type        = string

  validation {
    condition = contains([
      "azurerm_resource_group",
      "azurerm_storage_account",
      "azurerm_key_vault",
      "azurerm_key_vault_certificate",
      "azurerm_key_vault_secret",
      "azurerm_virtual_network",
      "azurerm_subnet",
      "azurerm_network_security_group",
      "azurerm_public_ip",
      "azurerm_application_gateway",
      "azurerm_load_balancer",
      "azurerm_virtual_machine",
      "azurerm_windows_virtual_machine",
      "azurerm_linux_virtual_machine",
      "azurerm_kubernetes_cluster",
      "azurerm_container_registry",
      "azurerm_container_app",
      "azurerm_container_app_environment",
      "azurerm_app_service_plan",
      "azurerm_service_plan",
      "azurerm_linux_web_app",
      "azurerm_windows_web_app",
      "azurerm_function_app",
      "azurerm_linux_function_app",
      "azurerm_windows_function_app",
      "azurerm_mssql_server",
      "azurerm_mssql_database",
      "azurerm_mysql_server",
      "azurerm_mysql_flexible_server",
      "azurerm_postgresql_server",
      "azurerm_postgresql_flexible_server",
      "azurerm_cosmosdb_account",
      "azurerm_redis_cache",
      "azurerm_cognitive_account",
      "azurerm_ai_services",
      "azurerm_api_management_user",
      "azurerm_express_route_circuit_peering",
      "azurerm_express_route_connection",
      "azurerm_application_insights",
      "azurerm_log_analytics_workspace",
      "azurerm_monitor_action_group",
      "azurerm_eventgrid_topic",
      "azurerm_eventhub_namespace",
      "azurerm_eventhub",
      "azurerm_servicebus_namespace",
      "azurerm_servicebus_topic",
      "azurerm_servicebus_queue",
      "azurerm_api_management",
      "azurerm_data_factory",
      "azurerm_synapse_workspace",
      "azurerm_recovery_services_vault",
      "azurerm_backup_vault",
      "azurerm_automation_account",
      "azurerm_cdn_profile",
      "azurerm_cdn_frontdoor_profile",
      "azurerm_cdn_frontdoor_endpoint",
      "azurerm_managed_disk",
      "azurerm_network_interface",
      "azurerm_aadb2c_directory",
      "azurerm_active_directory_domain_service",
      "azurerm_private_endpoint",
      "azurerm_private_dns_zone",
      "azurerm_route_table",
      "azurerm_user_assigned_identity",
      "azurerm_role_assignment",
      "azurerm_policy_definition",
      "azurerm_policy_assignment",
      "azurerm_management_group",
      "azurerm_monitor_diagnostic_setting",
      "azurerm_security_center_contact",
      "azurerm_security_center_workspace",
      "azurerm_static_web_app_custom_domain",
      "azurerm_api_management_api",
      "azurerm_api_management_api_diagnostic",
      "azurerm_api_management_api_operation",
      "azurerm_api_management_api_operation_policy",
      "azurerm_api_management_api_operation_tag",
      "azurerm_api_management_api_policy",
      "azurerm_api_management_backend",
      "azurerm_api_management_certificate",
      "azurerm_api_management_custom_domain",
      "azurerm_api_management_diagnostic",
      "azurerm_api_management_gateway",
      "azurerm_api_management_group",
      "azurerm_api_management_logger",
      "azurerm_api_management_product",
      "azurerm_api_management_subscription",
      "azurerm_api_management_user",
      "azurerm_app_configuration",
      "azurerm_app_service_environment_v3",
      "azurerm_application_security_group",
      "azurerm_availability_set",
      "azurerm_communication_service",
      "azurerm_consumption_budget_resource_group",
      "azurerm_consumption_budget_subscription",
      "azurerm_container_app_environment_certificate",
      "azurerm_container_app_environment_dapr_component",
      "azurerm_container_app_environment_storage",
      "azurerm_cosmosdb_sql_role_definition",
      "azurerm_data_factory_integration_runtime_azure_ssis",
      "azurerm_data_factory_integration_runtime_self_hosted",
      "azurerm_data_factory_pipeline",
      "azurerm_data_factory_trigger_schedule",
      "azurerm_data_protection_backup_vault",
      "azurerm_database_migration_project",
      "azurerm_database_migration_service",
      "azurerm_databricks_access_connector",
      "azurerm_databricks_workspace",
      "azurerm_dedicated_host",
      "azurerm_dedicated_host_group",
      "azurerm_disk_encryption_set",
      "azurerm_dns_zone",
      "azurerm_express_route_circuit",
      "azurerm_firewall_application_rule_collection",
      "azurerm_firewall_nat_rule_collection",
      "azurerm_firewall_network_rule_collection",
      "azurerm_firewall_policy",
      "azurerm_iotcentral_application",
      "azurerm_iothub",
      "azurerm_iothub_consumer_group",
      "azurerm_iothub_dps",
      "azurerm_ip_group",
      "azurerm_lb",
      "azurerm_lb_backend_address_pool",
      "azurerm_lb_backend_address_pool_address",
      "azurerm_lb_nat_pool",
      "azurerm_lb_nat_rule",
      "azurerm_lb_outbound_rule",
      "azurerm_lb_probe",
      "azurerm_lb_rule",
      "azurerm_load_test",
      "azurerm_local_network_gateway",
      "azurerm_log_analytics_solution",
      "azurerm_log_analytics_storage_insights",
      "azurerm_logic_app_action_custom",
      "azurerm_logic_app_action_http",
      "azurerm_logic_app_integration_account",
      "azurerm_logic_app_standard",
      "azurerm_logic_app_trigger_custom",
      "azurerm_logic_app_trigger_http_request",
      "azurerm_logic_app_trigger_recurrence",
      "azurerm_logic_app_workflow",
      "azurerm_machine_learning_compute_instance",
      "azurerm_machine_learning_workspace",
      "azurerm_maintenance_configuration",
      "azurerm_maps_account",
      "azurerm_monitor_activity_log_alert",
      "azurerm_monitor_metric_alert",
      "azurerm_mssql_elasticpool",
      "azurerm_mssql_managed_database",
      "azurerm_netapp_account",
      "azurerm_network_interface_backend_address_pool_association",
      "azurerm_network_manager",
      "azurerm_network_profile",
      "azurerm_network_security_rule",
      "azurerm_network_watcher",
      "azurerm_palo_alto_local_rulestack",
      "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack",
      "azurerm_powerbi_embedded",
      "azurerm_private_dns_resolver",
      "azurerm_private_dns_resolver_dns_forwarding_ruleset",
      "azurerm_private_dns_resolver_forwarding_rule",
      "azurerm_private_dns_resolver_inbound_endpoint",
      "azurerm_private_dns_resolver_outbound_endpoint",
      "azurerm_private_dns_resolver_virtual_network_link",
      "azurerm_proximity_placement_group",
      "azurerm_purview_account",
      "azurerm_relay_hybrid_connection",
      "azurerm_relay_namespace",
      "azurerm_resource_group_template_deployment",
      "azurerm_role_definition",
      "azurerm_search_service",
      "azurerm_shared_image",
      "azurerm_shared_image_gallery",
      "azurerm_signalr_service",
      "azurerm_subscription",
      "azurerm_virtual_desktop_application",
      "azurerm_virtual_desktop_application_group",
      "azurerm_virtual_desktop_host_pool",
      "azurerm_virtual_desktop_workspace",
      "azurerm_virtual_network_gateway_connection",
      "azurerm_virtual_network_gateway",
      "azurerm_virtual_wan",
      "azurerm_vmware_cluster",
      "azurerm_vmware_express_route_authorization",
      "azurerm_web_application_firewall_policy",
      "azurerm_private_dns_zone_virtual_network_link",
      "azurerm_public_ip_prefix",
      "azurerm_route",
      "azurerm_virtual_hub_connection",
      "azurerm_firewall",
      "azurerm_firewall_policy_rule_collection_group",
      "azurerm_nat_gateway",
      "azurerm_vpn_site",
      "azurerm_vpn_gateway_connection",
      "azurerm_vpn_gateway_nat_rule"
    ], var.resource_type)
    error_message = "The resource_type must be a supported Azure resource type."
  }
}

variable "name" {
  description = "Base name for the resource"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Name cannot be empty."
  }
}

variable "environment" {
  description = "Environment name (e.g., development, production, staging) - will be automatically converted to abbreviation"
  type        = string
  default     = ""

  validation {
    condition     = var.environment == "" || can(regex("^[a-zA-Z0-9-_]{2,20}$", var.environment))
    error_message = "Environment must be 2-20 alphanumeric characters, hyphens, or underscores, or empty."
  }
}

variable "region" {
  description = "Azure region name (e.g., eastus, westeurope) - will be automatically converted to abbreviation"
  type        = string
  default     = ""

  validation {
    condition     = var.region == "" || can(regex("^[a-zA-Z0-9-_]{2,30}$", var.region))
    error_message = "Region must be 2-30 alphanumeric characters, hyphens, or underscores, or empty."
  }
}

variable "instance" {
  description = "Instance number or identifier"
  type        = string
  default     = ""

  validation {
    condition     = var.instance == "" || can(regex("^[a-zA-Z0-9]{1,3}$", var.instance))
    error_message = "Instance must be 1-3 alphanumeric characters or empty."
  }
}

variable "prefix" {
  description = "Prefix to add to the resource name"
  type        = string
  default     = ""
}

variable "suffix" {
  description = "Suffix to add to the resource name"
  type        = string
  default     = ""
}

variable "separator" {
  description = "Character used to separate name components"
  type        = string
  default     = "-"

  validation {
    condition     = contains(["-", "_", "."], var.separator)
    error_message = "Separator must be one of: -, _, ."
  }
}

variable "clean_input" {
  description = "Whether to clean invalid characters from the name"
  type        = bool
  default     = true
}

variable "add_random" {
  description = "Whether to add random suffix for globally unique resources"
  type        = bool
  default     = false
}

variable "random_length" {
  description = "Length of random suffix to add"
  type        = number
  default     = 4

  validation {
    condition     = var.random_length >= 0 && var.random_length <= 8
    error_message = "Random length must be between 0 and 8."
  }
}

variable "validate" {
  description = "Whether to validate the generated name"
  type        = bool
  default     = true
}

variable "component_order" {
  description = <<DESCRIPTION
  The order of name components. This list defines the order in which the name components will be assembled.
  Available components: "prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"
  
  Default order: ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]
  
  Example custom order: ["prefix", "name", "environment", "abbreviation", "region", "instance", "suffix"]
  
  Note: All components are optional except "name" and "abbreviation" which are always included if provided.
  Empty or null components are automatically filtered out during name generation.
  DESCRIPTION
  type        = list(string)
  default     = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

  validation {
    condition = alltrue([
      for component in var.component_order : contains(["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"], component)
    ])
    error_message = "All components in component_order must be one of: prefix, abbreviation, name, environment, region, instance, suffix"
  }

  validation {
    condition     = contains(var.component_order, "name")
    error_message = "Component order must include 'name' component."
  }

  validation {
    condition     = contains(var.component_order, "abbreviation")
    error_message = "Component order must include 'abbreviation' component."
  }

  validation {
    condition     = length(var.component_order) == length(distinct(var.component_order))
    error_message = "Component order must not contain duplicate components."
  }
}
