variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication and landing zone key."
  type        = any
}

variable "location" {
  description = "Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = "Configuration settings for the resource."
  type        = any
}

variable "resource_group" {
  description = "Resource group object (provides name and location)."
  type        = any
}

variable "resource_group_name" {
  description = "Resource group name (optional, overrides resource_group.name)."
  type        = string
  default     = null
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for cross-module dependencies (diagnostics, vnets, virtual_subnets, private_dns, managed_identities, azure_monitor_workspaces)."
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Map of private endpoint configurations for Azure Managed Grafana."
  type        = any
  default     = {}
}
