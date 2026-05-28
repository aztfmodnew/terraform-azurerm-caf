# Split from variables.tf - group: platform_services

variable "subscription_billing_role_assignments" {
  type    = any
  default = {}
}

variable "ai_services" {
  type    = any
  default = {}
}

variable "resource_groups" {
  type    = any
  default = {}
}

variable "subnet_service_endpoint_storage_policies" {
  type    = any
  default = {}
}

variable "azurerm_redis_caches" {
  type    = any
  default = {}
}

variable "storage" {
  type    = any
  default = {}
}

variable "storage_accounts" {
  type    = any
  default = {}
}

variable "storage_account_static_websites" {
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

variable "ddos_services" {
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

variable "management_locks" {
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

variable "shared_image_galleries" {
  type    = any
  default = {}
}

variable "image_definitions" {
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

variable "dynamic_keyvault_secrets" {
  type    = any
  default = {}
}

variable "dynamic_keyvault_certificates" {
  type    = any
  default = {}
}

variable "local_network_gateways" {
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

variable "netapp_accounts" {
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

variable "vhub_peerings" {
  description = "Use virtual_hub_connections instead of vhub_peerings. It will be removed in version 6.0"
  type        = any
  default     = {}
}

variable "palo_alto_cloudngfws" {
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

variable "chaos_studio" {
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

variable "active_directory_domain_service" {
  type    = any
  default = {}
}

variable "active_directory_domain_service_replica_set" {
  type    = any
  default = {}
}

variable "app_config" {
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

variable "powerbi_embedded" {
  type    = any
  default = {}
}

variable "cdn_frontdoor_profiles" {
  description = "Configuring Front Door Profiles."
  default     = {}
  type        = any
}
