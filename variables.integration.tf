# Split from variables.tf - group: integration

variable "subscription_billing_role_assignments" {
  description = "Configuration object - subscription billing roleassignments."
  default     = {}
}

variable "billing" {
  description = "Configuration object - Billing information."
  default     = {}
}

variable "messaging" {
  description = "Configuration object - messaging resources"
  default     = {}
}

variable "event_hubs" {
  description = "Configuration object - Event Hub resources"
  default     = {}
}

variable "bot" {
  description = "Configuration object - Bot Service Resources"
  default     = {}
}

variable "communication" {
  description = "Configuration object - communication resources"
  default     = {}
}

variable "apim" {
  description = "Configuration object for API Management resources and routing-layer modules."
  default     = {}
}

variable "integration" {
  description = "Configuration object for integration services, including Azure API Center."
  default     = {}
}

variable "iot" {
  description = "Configuration object - IoT"
  default = {
    # digital_twins_instances                 = {}
    # digital_twins_endpoint_eventhubs                 = {}
    # digital_twins_endpoint_eventgrids = {}
    # digital_twins_endpoint_servicebuses = {}

  }
}

variable "resource_provider_registration" {
  default = {}
}
