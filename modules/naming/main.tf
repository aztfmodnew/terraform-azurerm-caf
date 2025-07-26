# Azure Naming Convention Module
# Based on Microsoft Azure naming best practices
# https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

locals {
  # Resource type abbreviations based on Microsoft recommendations
  resource_abbreviations = {
    "azurerm_resource_group"                                                     = "rg"
    "azurerm_storage_account"                                                    = "st"
    "azurerm_key_vault"                                                          = "kv"
    "azurerm_key_vault_certificate"                                              = "kvcert"
    "azurerm_key_vault_secret"                                                   = "kvsec"
    "azurerm_virtual_network"                                                    = "vnet"
    "azurerm_subnet"                                                             = "snet"
    "azurerm_network_security_group"                                             = "nsg"
    "azurerm_public_ip"                                                          = "pip"
    "azurerm_application_gateway"                                                = "agw"
    "azurerm_load_balancer"                                                      = "lb"
    "azurerm_virtual_machine"                                                    = "vm"
    "azurerm_windows_virtual_machine"                                            = "vm"
    "azurerm_linux_virtual_machine"                                              = "vm"
    "azurerm_kubernetes_cluster"                                                 = "aks"
    "azurerm_container_registry"                                                 = "acr"
    "azurerm_container_app"                                                      = "ca"
    "azurerm_container_app_environment"                                          = "cae"
    "azurerm_app_service_plan"                                                   = "asp"
    "azurerm_service_plan"                                                       = "asp"
    "azurerm_linux_web_app"                                                      = "app"
    "azurerm_windows_web_app"                                                    = "app"
    "azurerm_function_app"                                                       = "func"
    "azurerm_linux_function_app"                                                 = "func"
    "azurerm_windows_function_app"                                               = "func"
    "azurerm_mssql_server"                                                       = "sql"
    "azurerm_mssql_database"                                                     = "sqldb"
    "azurerm_mysql_server"                                                       = "mysql"
    "azurerm_mysql_flexible_server"                                              = "mysql"
    "azurerm_postgresql_server"                                                  = "psql"
    "azurerm_postgresql_flexible_server"                                         = "psql"
    "azurerm_cosmosdb_account"                                                   = "cosmos"
    "azurerm_redis_cache"                                                        = "redis"
    "azurerm_cognitive_account"                                                  = "cog"
    "azurerm_ai_services"                                                        = "ai"
    "azurerm_api_management_user"                                                = "apimusr"
    "azurerm_express_route_circuit_peering"                                      = "ercpeer"
    "azurerm_express_route_connection"                                           = "ercon"
    "azurerm_application_insights"                                               = "appi"
    "azurerm_log_analytics_workspace"                                            = "log"
    "azurerm_monitor_action_group"                                               = "ag"
    "azurerm_eventgrid_topic"                                                    = "egt"
    "azurerm_eventhub_namespace"                                                 = "evhns"
    "azurerm_eventhub"                                                           = "evh"
    "azurerm_servicebus_namespace"                                               = "sbns"
    "azurerm_servicebus_topic"                                                   = "sbt"
    "azurerm_servicebus_queue"                                                   = "sbq"
    "azurerm_api_management"                                                     = "apim"
    "azurerm_data_factory"                                                       = "adf"
    "azurerm_synapse_workspace"                                                  = "syn"
    "azurerm_recovery_services_vault"                                            = "rsv"
    "azurerm_backup_vault"                                                       = "bv"
    "azurerm_automation_account"                                                 = "aa"
    "azurerm_cdn_profile"                                                        = "cdnp"
    "azurerm_cdn_frontdoor_profile"                                              = "afd"
    "azurerm_cdn_frontdoor_endpoint"                                             = "fde"
    "azurerm_managed_disk"                                                       = "disk"
    "azurerm_network_interface"                                                  = "nic"
    "azurerm_aadb2c_directory"                                                   = "aadb2c"
    "azurerm_active_directory_domain_service"                                    = "aadds"
    "azurerm_private_endpoint"                                                   = "pe"
    "azurerm_private_dns_zone"                                                   = "pdns"
    "azurerm_route_table"                                                        = "rt"
    "azurerm_user_assigned_identity"                                             = "id"
    "azurerm_role_assignment"                                                    = "ra"
    "azurerm_policy_definition"                                                  = "policy"
    "azurerm_policy_assignment"                                                  = "assign"
    "azurerm_management_group"                                                   = "mg"
    "azurerm_monitor_diagnostic_setting"                                         = "diag"
    "azurerm_security_center_contact"                                            = "sc"
    "azurerm_security_center_workspace"                                          = "scws"
    "azurerm_static_web_app_custom_domain"                                       = "stapp-domain"
    "azurerm_api_management_api"                                                 = "apim-api"
    "azurerm_api_management_api_diagnostic"                                      = "apim-api-diag"
    "azurerm_api_management_api_operation"                                       = "apim-api-op"
    "azurerm_api_management_api_operation_policy"                                = "apim-api-op-policy"
    "azurerm_api_management_api_operation_tag"                                   = "apim-api-op-tag"
    "azurerm_api_management_api_policy"                                          = "apim-api-policy"
    "azurerm_api_management_backend"                                             = "apim-backend"
    "azurerm_api_management_certificate"                                         = "apim-cert"
    "azurerm_api_management_custom_domain"                                       = "apim-domain"
    "azurerm_api_management_diagnostic"                                          = "apim-diag"
    "azurerm_api_management_gateway"                                             = "apim-gw"
    "azurerm_api_management_group"                                               = "apim-group"
    "azurerm_api_management_logger"                                              = "apim-logger"
    "azurerm_api_management_product"                                             = "apim-product"
    "azurerm_api_management_subscription"                                        = "apim-sub"
    "azurerm_api_management_user"                                                = "apim-user"
    "azurerm_app_configuration"                                                  = "appcs"
    "azurerm_app_service_environment_v3"                                         = "asev3"
    "azurerm_application_security_group"                                         = "asg"
    "azurerm_availability_set"                                                   = "avail"
    "azurerm_communication_service"                                              = "acs"
    "azurerm_consumption_budget_resource_group"                                  = "budget-rg"
    "azurerm_consumption_budget_subscription"                                    = "budget-sub"
    "azurerm_container_app_environment_certificate"                              = "cae-cert"
    "azurerm_container_app_environment_dapr_component"                           = "cae-dapr"
    "azurerm_container_app_environment_storage"                                  = "cae-storage"
    "azurerm_cosmosdb_sql_role_definition"                                       = "cosmos-role"
    "azurerm_data_factory_integration_runtime_azure_ssis"                        = "adf-ir-ssis"
    "azurerm_data_factory_integration_runtime_self_hosted"                       = "adf-ir-sh"
    "azurerm_data_factory_pipeline"                                              = "adf-pipeline"
    "azurerm_data_factory_trigger_schedule"                                      = "adf-trigger"
    "azurerm_data_protection_backup_vault"                                       = "dpbv"
    "azurerm_database_migration_project"                                         = "dmp"
    "azurerm_database_migration_service"                                         = "dms"
    "azurerm_databricks_access_connector"                                        = "dbricks-ac"
    "azurerm_databricks_workspace"                                               = "dbricks"
    "azurerm_dedicated_host"                                                     = "dhost"
    "azurerm_dedicated_host_group"                                               = "dhg"
    "azurerm_disk_encryption_set"                                                = "des"
    "azurerm_dns_zone"                                                           = "dns"
    "azurerm_express_route_circuit"                                              = "erc"
    "azurerm_firewall_application_rule_collection"                               = "fwl-arc"
    "azurerm_firewall_nat_rule_collection"                                       = "fwl-nrc"
    "azurerm_firewall_network_rule_collection"                                   = "fwl-nrc"
    "azurerm_firewall_policy"                                                    = "fwpol"
    "azurerm_iotcentral_application"                                             = "iotc"
    "azurerm_iothub"                                                             = "iothub"
    "azurerm_iothub_consumer_group"                                              = "iothub-cg"
    "azurerm_iothub_dps"                                                         = "dps"
    "azurerm_ip_group"                                                           = "ipg"
    "azurerm_lb"                                                                 = "lb"
    "azurerm_lb_backend_address_pool"                                            = "lb-bep"
    "azurerm_lb_backend_address_pool_address"                                    = "lb-bep-addr"
    "azurerm_lb_nat_pool"                                                        = "lb-natp"
    "azurerm_lb_nat_rule"                                                        = "lb-natr"
    "azurerm_lb_outbound_rule"                                                   = "lb-outr"
    "azurerm_lb_probe"                                                           = "lb-probe"
    "azurerm_lb_rule"                                                            = "lb-rule"
    "azurerm_load_test"                                                          = "lt"
    "azurerm_local_network_gateway"                                              = "lng"
    "azurerm_log_analytics_solution"                                             = "las"
    "azurerm_log_analytics_storage_insights"                                     = "lasi"
    "azurerm_logic_app_action_custom"                                            = "logic-action"
    "azurerm_logic_app_action_http"                                              = "logic-http"
    "azurerm_logic_app_integration_account"                                      = "logic-ia"
    "azurerm_logic_app_standard"                                                 = "logic-std"
    "azurerm_logic_app_trigger_custom"                                           = "logic-trigger"
    "azurerm_logic_app_trigger_http_request"                                     = "logic-http-req"
    "azurerm_logic_app_trigger_recurrence"                                       = "logic-rec"
    "azurerm_logic_app_workflow"                                                 = "logic"
    "azurerm_machine_learning_compute_instance"                                  = "mlci"
    "azurerm_machine_learning_workspace"                                         = "mlw"
    "azurerm_maintenance_configuration"                                          = "mc"
    "azurerm_maps_account"                                                       = "map"
    "azurerm_monitor_activity_log_alert"                                         = "ala"
    "azurerm_monitor_metric_alert"                                               = "ma"
    "azurerm_mssql_elasticpool"                                                  = "sqlep"
    "azurerm_mssql_managed_database"                                             = "sqlmidb"
    "azurerm_netapp_account"                                                     = "naa"
    "azurerm_network_interface_backend_address_pool_association"                 = "nic-bep"
    "azurerm_network_manager"                                                    = "nm"
    "azurerm_network_profile"                                                    = "np"
    "azurerm_network_security_rule"                                              = "nsr"
    "azurerm_network_watcher"                                                    = "nw"
    "azurerm_palo_alto_local_rulestack"                                          = "palrs"
    "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack" = "pangfw"
    "azurerm_powerbi_embedded"                                                   = "pbi"
    "azurerm_private_dns_resolver"                                               = "dnspr"
    "azurerm_private_dns_resolver_dns_forwarding_ruleset"                        = "dnspr-frs"
    "azurerm_private_dns_resolver_forwarding_rule"                               = "dnspr-rule"
    "azurerm_private_dns_resolver_inbound_endpoint"                              = "dnspr-in"
    "azurerm_private_dns_resolver_outbound_endpoint"                             = "dnspr-out"
    "azurerm_private_dns_resolver_virtual_network_link"                          = "dnspr-vnl"
    "azurerm_proximity_placement_group"                                          = "ppg"
    "azurerm_purview_account"                                                    = "pview"
    "azurerm_relay_hybrid_connection"                                            = "rlhc"
    "azurerm_relay_namespace"                                                    = "rln"
    "azurerm_resource_group_template_deployment"                                 = "rgdep"
    "azurerm_role_definition"                                                    = "role"
    "azurerm_search_service"                                                     = "srch"
    "azurerm_shared_image"                                                       = "si"
    "azurerm_shared_image_gallery"                                               = "sig"
    "azurerm_signalr_service"                                                    = "signalr"
    "azurerm_subscription"                                                       = "sub"
    "azurerm_virtual_desktop_application"                                        = "vda"
    "azurerm_virtual_desktop_application_group"                                  = "vdag"
    "azurerm_virtual_desktop_host_pool"                                          = "vdhp"
    "azurerm_virtual_desktop_workspace"                                          = "vdws"
    "azurerm_virtual_network_gateway_connection"                                 = "vngc"
    "azurerm_virtual_network_gateway"                                            = "vng"
    "azurerm_virtual_wan"                                                        = "vwan"
    "azurerm_vmware_cluster"                                                     = "vmwc"
    "azurerm_vmware_express_route_authorization"                                 = "vmw-era"
    "azurerm_web_application_firewall_policy"                                    = "wafpol"
    "azurerm_private_dns_zone_virtual_network_link"                              = "pdnslnk"
    "azurerm_public_ip_prefix"                                                   = "ippre"
    "azurerm_route"                                                              = "rt"
    "azurerm_virtual_hub_connection"                                             = "vhubcon"
    "azurerm_firewall"                                                           = "fw"
    "azurerm_firewall_policy_rule_collection_group"                              = "fwprcg"
    "azurerm_nat_gateway"                                                        = "natgw"
    "azurerm_vpn_site"                                                           = "vpnsite"
    "azurerm_vpn_gateway_connection"                                             = "vpngwcon"
    "azurerm_vpn_gateway_nat_rule"                                               = "vpngwnat"
  }

  # Resource naming restrictions based on Azure documentation
  resource_constraints = {
    "azurerm_resource_group" = {
      min_length      = 1
      max_length      = 90
      allowed_chars   = "a-zA-Z0-9-_()."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_storage_account" = {
      min_length      = 3
      max_length      = 24
      allowed_chars   = "a-z0-9"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = []
      start_end_rules = "alphanumeric"
    }
    "azurerm_key_vault" = {
      min_length      = 3
      max_length      = 24
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_key_vault_certificate" = {
      min_length      = 1
      max_length      = 127
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_key_vault_secret" = {
      min_length      = 1
      max_length      = 127
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_virtual_network" = {
      min_length      = 2
      max_length      = 64
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_", "."]
      start_end_rules = "alphanumeric"
    }
    "azurerm_subnet" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_", "."]
      start_end_rules = "alphanumeric"
    }
    "azurerm_kubernetes_cluster" = {
      min_length      = 1
      max_length      = 63
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_container_registry" = {
      min_length      = 5
      max_length      = 50
      allowed_chars   = "a-zA-Z0-9"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = []
      start_end_rules = "alphanumeric"
    }
    "azurerm_linux_web_app" = {
      min_length      = 2
      max_length      = 60
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_windows_web_app" = {
      min_length      = 2
      max_length      = 60
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_mssql_server" = {
      min_length      = 1
      max_length      = 63
      allowed_chars   = "a-z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_cosmosdb_account" = {
      min_length      = 3
      max_length      = 44
      allowed_chars   = "a-z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_aadb2c_directory" = {
      min_length      = 1
      max_length      = 27
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_static_web_app_custom_domain" = {
      min_length      = 1
      max_length      = 253
      allowed_chars   = "a-zA-Z0-9-."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "."]
      start_end_rules = "alphanumeric"
    }
    "azurerm_dns_zone" = {
      min_length      = 1
      max_length      = 63
      allowed_chars   = "a-zA-Z0-9-."
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-", "."]
      start_end_rules = "alphanumeric"
    }
    "azurerm_search_service" = {
      min_length      = 2
      max_length      = 60
      allowed_chars   = "a-z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_communication_service" = {
      min_length      = 1
      max_length      = 63
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_signalr_service" = {
      min_length      = 3
      max_length      = 63
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = true
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_machine_learning_workspace" = {
      min_length      = 3
      max_length      = 33
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_netapp_account" = {
      min_length      = 1
      max_length      = 128
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_subscription" = {
      min_length      = 1
      max_length      = 64
      allowed_chars   = "a-zA-Z0-9-_ ."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_shared_image_gallery" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_virtual_network_gateway" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_private_dns_zone_virtual_network_link" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_public_ip_prefix" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_route" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_virtual_hub_connection" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_firewall" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_nat_gateway" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_vpn_site" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_firewall_policy_rule_collection_group" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_vpn_gateway_connection" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_vpn_gateway_nat_rule" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_api_management_user" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_express_route_circuit_peering" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_express_route_connection" = {
      min_length      = 1
      max_length      = 80
      allowed_chars   = "a-zA-Z0-9-_."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "_"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_container_app" = {
      min_length      = 2
      max_length      = 32
      allowed_chars   = "a-z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_container_app_environment" = {
      min_length      = 2
      max_length      = 60
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_container_app_environment_certificate" = {
      min_length      = 1
      max_length      = 253
      allowed_chars   = "a-zA-Z0-9-."
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-", "."]
      start_end_rules = "alphanumeric"
    }
    "azurerm_container_app_environment_dapr_component" = {
      min_length      = 1
      max_length      = 60
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
    "azurerm_container_app_environment_storage" = {
      min_length      = 1
      max_length      = 60
      allowed_chars   = "a-zA-Z0-9-"
      case_sensitive  = false
      global_unique   = false
      no_consecutive  = ["-"]
      start_end_rules = "alphanumeric"
    }
  }

  # Build name components
  abbreviation = lookup(local.resource_abbreviations, var.resource_type, "resource")

  # Create component map with automatic conversions
  component_map = {
    "prefix"       = var.prefix
    "abbreviation" = local.abbreviation
    "name"         = var.name
    "environment"  = local.environment_abbr # Use converted abbreviation
    "region"       = local.region_abbr      # Use converted abbreviation
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
    min_length      = 1
    max_length      = 63
    allowed_chars   = "a-zA-Z0-9-"
    case_sensitive  = false
    global_unique   = false
    no_consecutive  = ["-"]
    start_end_rules = "alphanumeric"
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

# Validation checks using terraform_data (more modern than null_resource)
resource "terraform_data" "validation" {
  count = var.validate ? 1 : 0

  input = {
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
