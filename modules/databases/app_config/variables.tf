variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
  # For the future
  /*type = object({
    sku_name = optional(string)
    local_auth_enabled = optional(bool)
    public_network_access = optional(bool)
    identity = optional(object({
      type = string
    }))
    tags = optional(map(string))
    private_endpoints = optional(map(object({
      name = string
      lz_key = optional(string)
      vnet_key = string
      subnet_key = string
      subnet_id = optional(string)
    })))
    dynamic_settings = optional(map(map(map(object({
      lz_key = optional(string)
      attribute_key = string
    })))))
  })*/
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "location" {
  description = "location of the resource if different from the resource group."
  type        = string
  default     = null
}
variable "resource_group_name" {
  description = "Resource group object to deploy the Azure resource"
  type        = string
  default     = null
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "name" {
  description = "(Required) Name of the App Config"
  type        = string
}

variable "combined_objects" {
  description = "Combined objects for the resource."
  type        = map(any)
  default     = {}
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "vnets" {
  description = "Virtual networks for the resource."
  type        = map(any)
  default     = {}
}
variable "private_dns" {
  description = "Private DNS settings for the resource."
  type        = map(any)
  default     = {}
}
