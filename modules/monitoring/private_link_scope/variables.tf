variable "global_settings" {
  description = "Global settings object."
  type        = any
}

variable "client_config" {
  description = "Client configuration object."
  type        = any
}

variable "settings" {
  description = "Azure Monitor Private Link Scope, scoped services, private endpoints, and timeout configuration."
  type        = any
}

variable "remote_objects" {
  description = "Combined resource groups, workspaces, Application Insights components, networks, and private DNS zones."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Whether to inherit resource group and global tags."
  type        = bool
  default     = false
}
