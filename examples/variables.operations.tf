# Split from variables.tf - group: operations

variable "consumption_budgets" {
  type    = any
  default = {}
}

variable "diagnostics_definition" {
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

variable "grafana" {
  type    = any
  default = {}
}

variable "log_analytics" {
  type    = any
  default = {}
}

variable "diagnostics_destinations" {
  type    = any
  default = {}
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

variable "preview_features" {
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

variable "maintenance_assignment_dynamic_scope" {
  type    = any
  default = {}
}

variable "load_test" {
  default = {}
  type    = any
}

variable "invoice_sections" {
  description = "Configuration object - Billing Invoice Section resources."
  default     = {}
}
