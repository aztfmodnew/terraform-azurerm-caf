variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "base_tags" {
  description = "Enable tags inheritance from global settings."
  type        = bool
  default     = false
}

variable "resource_group" {
  description = "Resource group object (for tag inheritance)."
  type        = any
  default     = null
}

variable "automation_account_id" {
  description = "The ID of the Automation Account where the module will be deployed."
  type        = string
}

variable "settings" {
  description = "Settings object for the Automation Powershell 7.2 Module with attributes: name, module_link (with uri and optional hash), optional timeouts, and optional tags."
  type = object({
    name = string
    module_link = object({
      uri  = string
      hash = optional(object({
        algorithm = string
        value     = string
      }))
    })
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    tags = optional(map(string))
  })
  validation {
    condition = length(setsubtract(keys(var.settings), ["name", "module_link", "timeouts", "tags"])) == 0
    error_message = "Unsupported attributes in settings. Allowed: name, module_link, timeouts, tags."
  }
}
