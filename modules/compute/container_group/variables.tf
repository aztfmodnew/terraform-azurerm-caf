variable "base_tags" {
  type = map(any)
}

variable "client_config" {
  type = any
}

variable "diagnostic_profiles" {
  type = any
}

variable "combined_diagnostics" {
  type = any
}

variable "combined_resources" {
  description = "Provide a map of combined resources for environment_variables_from_resources"
  default     = {}
  type        = any
}

variable "global_settings" {
  type = any
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "dynamic_keyvault_secrets" {
  description = "Provide credentials for private image registries"
  default     = {}
  type        = any
}

variable "remote_objects" {
  description = <<DESCRIPTION
  Remote objects is a map of objects. Each object represents a remote object that the Cognitive Service Account depends on.
  - `vnets`: (Optional) A map of virtual networks.
  - `virtual_subnets`: (Optional) A map of virtual subnets.
  DESCRIPTION
  type        = any
  default     = {}
}