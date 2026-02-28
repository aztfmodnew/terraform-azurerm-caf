variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "resource_group" {
  description = "(Optional) Resource group object used for tag inheritance."
  default     = null
}

variable "resource_groups" {
  description = "(Optional) Map of resource group objects for filter resolution."
  default     = {}
}

variable "base_tags" {
  description = "(Optional) Inherit tags from the resource group. Defaults to false."
  type        = bool
  default     = false
}

variable "maintenance_configuration_id" {
  description = "(Required) Specifies the ID of the Maintenance Configuration Resource. Changing this forces a new resource to be created."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for Azure Dynamic Maintenance Assignment. Configuration attributes:
      - name           - (Required) Name of the assignment. Must be unique per subscription.
      - filter         - (Required) Filter block for dynamic scope selection.
        - locations       - (Optional) List of locations to scope.
        - os_types        - (Optional) List of allowed OS types: Linux, Windows.
        - resource_groups - (Optional) List of allowed resource group names.
        - resource_types  - (Optional) List of allowed resource types.
        - tag_filter      - (Optional) Filter VMs by Any or All specified tags. Defaults to Any.
        - tags            - (Optional) Map of tag blocks with tag and values attributes.
        - resource_group_key - (Optional) Key reference for resource group lookup.
      - timeouts        - (Optional) Timeout overrides for create/read/update/delete.
    DESCRIPTION
  type = object({
    name = string
    filter = optional(object({
      locations          = optional(list(string), [])
      os_types           = optional(list(string), [])
      resource_groups    = optional(list(string), [])
      resource_types     = optional(list(string), [])
      tag_filter         = optional(string, "Any")
      resource_group_key = optional(list(string))
      resources_groups   = optional(map(any))
      tags = optional(map(object({
        tag    = string
        values = list(string)
      })))
    }))
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
}
