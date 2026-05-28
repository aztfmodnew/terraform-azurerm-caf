# Split from variables.tf - group: integration

variable "event_hub_namespaces" {
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

variable "automation_powershell72_module" {
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

variable "event_hub_auth_rules" {
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

variable "azure_bots" {
  type    = any
  default = {}
}

variable "communication_services" {
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

variable "runbooks" {
  type    = any
  default = {}
}

variable "resource_provider_registration" {
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
