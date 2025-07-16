# Azure Naming Convention Module
# Based on Microsoft Azure naming best practices
# https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

locals {
  # Resource type abbreviations based on Microsoft recommendations
  resource_abbreviations = {
    "azurerm_resource_group"                     = "rg"
    "azurerm_storage_account"                    = "st"
    "azurerm_key_vault"                          = "kv"
    "azurerm_virtual_network"                    = "vnet"
    "azurerm_subnet"                             = "snet"
    "azurerm_network_security_group"             = "nsg"
    "azurerm_public_ip"                          = "pip"
    "azurerm_application_gateway"                = "agw"
    "azurerm_load_balancer"                      = "lb"
    "azurerm_virtual_machine"                    = "vm"
    "azurerm_windows_virtual_machine"            = "vm"
    "azurerm_linux_virtual_machine"              = "vm"
    "azurerm_kubernetes_cluster"                 = "aks"
    "azurerm_container_registry"                 = "acr"
    "azurerm_container_app"                      = "ca"
    "azurerm_container_app_environment"          = "cae"
    "azurerm_app_service_plan"                   = "asp"
    "azurerm_service_plan"                       = "asp"
    "azurerm_linux_web_app"                      = "app"
    "azurerm_windows_web_app"                    = "app"
    "azurerm_function_app"                       = "func"
    "azurerm_linux_function_app"                 = "func"
    "azurerm_windows_function_app"               = "func"
    "azurerm_mssql_server"                       = "sql"
    "azurerm_mssql_database"                     = "sqldb"
    "azurerm_mysql_server"                       = "mysql"
    "azurerm_mysql_flexible_server"              = "mysql"
    "azurerm_postgresql_server"                  = "psql"
    "azurerm_postgresql_flexible_server"         = "psql"
    "azurerm_cosmosdb_account"                   = "cosmos"
    "azurerm_redis_cache"                        = "redis"
    "azurerm_cognitive_account"                  = "cog"
    "azurerm_ai_services"                        = "ai"
    "azurerm_application_insights"               = "appi"
    "azurerm_log_analytics_workspace"            = "log"
    "azurerm_monitor_action_group"               = "ag"
    "azurerm_eventgrid_topic"                    = "egt"
    "azurerm_eventhub_namespace"                 = "evhns"
    "azurerm_eventhub"                           = "evh"
    "azurerm_servicebus_namespace"               = "sbns"
    "azurerm_servicebus_topic"                   = "sbt"
    "azurerm_servicebus_queue"                   = "sbq"
    "azurerm_api_management"                     = "apim"
    "azurerm_data_factory"                       = "adf"
    "azurerm_synapse_workspace"                  = "syn"
    "azurerm_recovery_services_vault"            = "rsv"
    "azurerm_backup_vault"                       = "bv"
    "azurerm_automation_account"                 = "aa"
    "azurerm_cdn_profile"                        = "cdnp"
    "azurerm_cdn_frontdoor_profile"              = "afd"
    "azurerm_cdn_frontdoor_endpoint"             = "fde"
    "azurerm_managed_disk"                       = "disk"
    "azurerm_network_interface"                  = "nic"
    "azurerm_aadb2c_directory"                   = "aadb2c"
    "azurerm_active_directory_domain_service"    = "aadds"
    "azurerm_private_endpoint"                   = "pe"
    "azurerm_private_dns_zone"                   = "pdns"
    "azurerm_route_table"                        = "rt"
    "azurerm_user_assigned_identity"             = "id"
    "azurerm_role_assignment"                    = "ra"
    "azurerm_policy_definition"                  = "policy"
    "azurerm_policy_assignment"                  = "assign"
    "azurerm_management_group"                   = "mg"
    "azurerm_monitor_diagnostic_setting"         = "diag"
    "azurerm_security_center_contact"            = "sc"
    "azurerm_security_center_workspace"          = "scws"
  }

  # Resource naming restrictions based on Azure documentation
  resource_constraints = {
    "azurerm_resource_group" = {
      min_length        = 1
      max_length        = 90
      allowed_chars     = "a-zA-Z0-9-_()."
      case_sensitive    = false
      global_unique     = false
      no_consecutive    = ["-", "_"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_storage_account" = {
      min_length        = 3
      max_length        = 24
      allowed_chars     = "a-z0-9"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = []
      start_end_rules   = "alphanumeric"
    }
    "azurerm_key_vault" = {
      min_length        = 3
      max_length        = 24
      allowed_chars     = "a-zA-Z0-9-"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_virtual_network" = {
      min_length        = 2
      max_length        = 64
      allowed_chars     = "a-zA-Z0-9-_."
      case_sensitive    = false
      global_unique     = false
      no_consecutive    = ["-", "_", "."]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_subnet" = {
      min_length        = 1
      max_length        = 80
      allowed_chars     = "a-zA-Z0-9-_."
      case_sensitive    = false
      global_unique     = false
      no_consecutive    = ["-", "_", "."]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_kubernetes_cluster" = {
      min_length        = 1
      max_length        = 63
      allowed_chars     = "a-zA-Z0-9-"
      case_sensitive    = false
      global_unique     = false
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_container_registry" = {
      min_length        = 5
      max_length        = 50
      allowed_chars     = "a-zA-Z0-9"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = []
      start_end_rules   = "alphanumeric"
    }
    "azurerm_linux_web_app" = {
      min_length        = 2
      max_length        = 60
      allowed_chars     = "a-zA-Z0-9-"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_windows_web_app" = {
      min_length        = 2
      max_length        = 60
      allowed_chars     = "a-zA-Z0-9-"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_mssql_server" = {
      min_length        = 1
      max_length        = 63
      allowed_chars     = "a-z0-9-"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_cosmosdb_account" = {
      min_length        = 3
      max_length        = 44
      allowed_chars     = "a-z0-9-"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
    "azurerm_aadb2c_directory" = {
      min_length        = 1
      max_length        = 27
      allowed_chars     = "a-zA-Z0-9-"
      case_sensitive    = false
      global_unique     = true
      no_consecutive    = ["-"]
      start_end_rules   = "alphanumeric"
    }
  }

  # Build name components
  abbreviation = lookup(local.resource_abbreviations, var.resource_type, "resource")
  
  # Create component map with automatic conversions
  component_map = {
    "prefix"       = var.prefix
    "abbreviation" = local.abbreviation
    "name"         = var.name
    "environment"  = local.environment_abbr  # Use converted abbreviation
    "region"       = local.region_abbr       # Use converted abbreviation
    "instance"     = var.instance != "" ? var.instance : null
    "suffix"       = var.suffix
  }
  
  # Build name parts in the specified order
  name_parts = compact([
    for component in var.component_order : 
    lookup(local.component_map, component, null) != null && lookup(local.component_map, component, null) != "" ? 
    lookup(local.component_map, component, null) : null
  ])

  # Join name parts with separator
  raw_name = join(var.separator, local.name_parts)

  # Get constraints for the resource type
  constraints = lookup(local.resource_constraints, var.resource_type, {
    min_length        = 1
    max_length        = 63
    allowed_chars     = "a-zA-Z0-9-"
    case_sensitive    = false
    global_unique     = false
    no_consecutive    = ["-"]
    start_end_rules   = "alphanumeric"
  })

  # Apply transformations based on constraints
  # Use replace function with regex pattern for cleaning
  cleaned_name = var.clean_input ? replace(local.raw_name, "/[^${local.constraints.allowed_chars}]/", "") : local.raw_name
  
  # Convert to lowercase if not case sensitive
  case_adjusted_name = local.constraints.case_sensitive ? local.cleaned_name : lower(local.cleaned_name)
  
  # Remove consecutive separators
  no_consecutive_name = replace(replace(local.case_adjusted_name, "--", "-"), "--", "-")
  
  # Ensure proper start/end characters
  start_end_adjusted = local.constraints.start_end_rules == "alphanumeric" ? trim(local.no_consecutive_name, "${var.separator}_-.") : local.no_consecutive_name
  
  # Truncate if too long
  length_adjusted = length(local.start_end_adjusted) > local.constraints.max_length ? substr(local.start_end_adjusted, 0, local.constraints.max_length) : local.start_end_adjusted
  
  # Add random suffix if global unique and requested
  final_name = var.add_random && local.constraints.global_unique && var.random_length > 0 ? "${local.length_adjusted}${random_string.suffix[0].result}" : local.length_adjusted
}

# Random string for uniqueness
resource "random_string" "suffix" {
  count   = var.add_random && lookup(local.constraints, "global_unique", false) && var.random_length > 0 ? 1 : 0
  length  = var.random_length
  upper   = false
  special = false
  numeric = true
}

# Validation checks
resource "null_resource" "validation" {
  count = var.validate ? 1 : 0
  
  triggers = {
    name_too_short = length(local.final_name) < local.constraints.min_length
    name_too_long  = length(local.final_name) > local.constraints.max_length
    invalid_chars  = can(regex("[^${local.constraints.allowed_chars}]", local.final_name))
  }
  
  lifecycle {
    precondition {
      condition     = length(local.final_name) >= local.constraints.min_length
      error_message = "Generated name '${local.final_name}' is too short. Minimum length is ${local.constraints.min_length} characters."
    }
    
    precondition {
      condition     = length(local.final_name) <= local.constraints.max_length
      error_message = "Generated name '${local.final_name}' is too long. Maximum length is ${local.constraints.max_length} characters."
    }
    
    precondition {
      condition     = !can(regex("[^${local.constraints.allowed_chars}]", local.final_name))
      error_message = "Generated name '${local.final_name}' contains invalid characters. Allowed characters: ${local.constraints.allowed_chars}"
    }
  }
}
