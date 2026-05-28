# Split from variables.tf - group: operations

variable "diagnostics_definition" {
  default     = null
  description = "Configuration object - Shared diadgnostics settings that can be used by the services to enable diagnostics."
}

variable "diagnostics_destinations" {
  description = "Configuration object - Describes the destinations for the diagnostics."
  default     = null
}

variable "log_analytics" {
  description = "Configuration object - Log Analytics resources."
  default     = {}
}

variable "monitoring" {
  description = "Configuration object - Monitoring resources (Service Health Alerts, Monitor Metric Alerts, etc.)."
  default     = {}
}

variable "dashboards" {
  description = "Configuration object - Dashboard resources (Grafana, Monitor Workspaces, etc.)."
  default     = {}
}

variable "diagnostics" {
  description = "Configuration object - Diagnostics object."
  default     = {}
}

variable "event_hub_namespaces" {
  description = "Configuration object - Diagnostics object."
  default     = {}
}

variable "chaos_studio" {
  description = "Configuration object - Chaos Studio resources"
  default     = {}
}

variable "preview_features" {
  default = {}
}

variable "maintenance" {
  default = {}
}

variable "invoice_sections" {
  description = "Configuration object - Billing Invoice Section resources"
  default     = {}
}
