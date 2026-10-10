variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the Fabric Capacity will be deployed."
  type        = string
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
    Settings for an Azure Fabric Capacity.

    Supported attributes:
      - name - (Optional) Name input used by CAF naming.
      - key - (Optional) Fallback CAF name input.
      - location - (Optional) Azure region override.
      - region - (Optional) Key in global_settings.regions.
      - resource_group - (Optional) Resource group key or name/location object.
      - resource_group_key - (Optional) CAF resource group key.
      - resource_group_name - (Optional) Resource group name override.
      - sku - (Required) SKU configuration. name must be one of F2, F4, F8,
        F16, F32, F64, F128, F256, F512, F1024, or F2048. tier defaults to
        Fabric and Fabric is the only supported tier.
      - administration_members - (Optional) Entra user UPNs or service
        principal object IDs that administer the capacity.
      - tags - (Optional) Tags to merge with inherited CAF tags.
      - timeouts - (Optional) Create, read, update, and delete operation timeouts.
    DESCRIPTION
  type = object({
    name     = optional(string)
    key      = optional(string)
    location = optional(string)
    region   = optional(string)
    resource_group = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      name     = optional(string)
      location = optional(string)
    }))
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    sku = optional(object({
      name = optional(string)
      tier = optional(string)
    }))
    administration_members = optional(list(string))
    tags                   = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
}

variable "resource_group" {
  description = "Resource group object that hosts the Fabric Capacity."
  type        = any
}

variable "base_tags" {
  description = "Flag indicating if tags should inherit from the resource group/global settings."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for cross-module dependencies."
  type        = any
  default     = {}
}
