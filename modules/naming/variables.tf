variable "resource_type" {
  description = "The type of Azure resource for which to generate a name"
  type        = string
  
  validation {
    condition = contains([
      "azurerm_resource_group",
      "azurerm_storage_account",
      "azurerm_key_vault",
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
      "azurerm_security_center_workspace"
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
    condition = var.environment == "" || can(regex("^[a-zA-Z0-9-_]{2,20}$", var.environment))
    error_message = "Environment must be 2-20 alphanumeric characters, hyphens, or underscores, or empty."
  }
}

variable "region" {
  description = "Azure region name (e.g., eastus, westeurope) - will be automatically converted to abbreviation"
  type        = string
  default     = ""
  
  validation {
    condition = var.region == "" || can(regex("^[a-zA-Z0-9-_]{2,30}$", var.region))
    error_message = "Region must be 2-30 alphanumeric characters, hyphens, or underscores, or empty."
  }
}

variable "instance" {
  description = "Instance number or identifier"
  type        = string
  default     = ""
  
  validation {
    condition = var.instance == "" || can(regex("^[a-zA-Z0-9]{1,3}$", var.instance))
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
