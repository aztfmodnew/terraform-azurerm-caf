# Split from variables.tf - group: data_analytics

variable "data_factory" {
  description = "Configuration object - Azure Data Factory resources"
  default     = {}
}

variable "logic_app" {
  description = "Configuration object - Azure Logic App resources"
  default     = {}
}

variable "database" {
  description = "Configuration object - databases resources"
  default     = {}
}

variable "analytics" {
  description = "Configuration object - analytics resources"
  type        = any
  default     = {}
}

variable "search_services" {
  description = "Configuration object - Search service Resource "
  default     = {}
}

variable "load_test" {
  description = "Configuration object - Load Test resources"
  default     = {}
}
