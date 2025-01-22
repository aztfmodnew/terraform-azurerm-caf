variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "tags" {
  description = "(Required) map of tags for the deployment"
  type        = map(any)
}

variable "name" {
  description = "(Required) Name of the Static Site"
  type        = string
}

variable "location" {
  description = "(Required) Resource Location"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group of the Static Site"
  type        = string
}

variable "sku_tier" {
  description = "Specifies the SKU tier of the Static Web App. Possible values are Free or Standard. Defaults to Free."
  type        = string
  default     = null

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "Allowed values are Free or Standard."
  }
}

variable "sku_size" {
  description = "Specifies the SKU size of the Static Web App. Possible values are Free or Standard. Defaults to Free."
  type        = string
  default     = null

  validation {
    condition     = contains(["Free", "Standard"], var.sku_size)
    error_message = "Allowed values are Free or Standard."
  }
}
variable "identity" {
  default = null
  type    = any
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

variable "diagnostic_profiles" {
  default = {}
  type    = map(any)
}

variable "diagnostics" {
  default = null
  type    = any
}

variable "custom_domains" {
  default = {}
  type    = map(any)
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}