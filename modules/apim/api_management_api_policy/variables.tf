variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
    Settings for the API Management API policy.

    Optional attributes:
      - api - API reference retained for compatibility with the root configuration.
      - api_management - API Management service reference retained for compatibility with the root configuration.
      - resource_group - Resource group reference retained for compatibility with the root configuration.
      - xml_content - XML content for the policy.
      - xml_link - Publicly available link to a policy XML document.
      - timeouts - Create, read, update, and delete operation timeouts.
  DESCRIPTION
  type = object({
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "api", "api_management", "resource_group", "xml_content", "xml_link", "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in settings. Allowed: api, api_management, resource_group, xml_content, xml_link, timeouts."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_name" {
  description = " The name of the API"
}
variable "api_management_name" {
  description = " The name of the API Management Service. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The name of the Resource Group in which the API Management Service exists. Changing this forces a new resource to be created."
}
