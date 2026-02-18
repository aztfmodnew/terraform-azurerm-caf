variable "global_settings" {
  description = "Global settings object for the CAF framework"
}

variable "client_config" {
  description = "Client configuration object for the CAF framework"
}

variable "location" {
  description = "Azure region where the resource will be created"
  type        = string
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Chaos Studio Target. Configuration attributes:
      - location - (Optional) Azure region for the target
      - target_resource_id - (Optional) Direct resource ID to enable chaos experiments on
      - target_resource - (Optional) Key-based reference to target resource (alternative to target_resource_id)
        - key - Resource key in the landing zone
        - lz_key - (Optional) Landing zone key for cross-landing-zone references
      - target_type - (Required) Target type in format [publisher]-[targetType] (e.g., Microsoft-StorageAccount)
        See supported types: https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-providers
    DESCRIPTION
  type = object({
    location           = optional(string)
    target_resource_id = optional(string)
    target_resource = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    target_type    = string
    resource_group = optional(any)
    tags           = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  validation {
    condition     = length(setsubtract(keys(var.settings), ["location", "target_resource_id", "target_resource", "target_type", "resource_group", "tags", "timeouts"])) == 0
    error_message = "Unsupported attributes in settings. Allowed: location, target_resource_id, target_resource, target_type, resource_group, tags, timeouts."
  }
}

variable "resource_group" {
  description = "Resource group object for the Chaos Studio Target"
}

variable "base_tags" {
  description = "Base tags to be applied to all resources"
  type        = bool
  default     = false
}

variable "remote_objects" {
  description = "Remote objects for dependency resolution"
  type = object({
    resource_groups            = optional(map(any), {})
    storage_accounts           = optional(map(any), {})
    virtual_machines           = optional(map(any), {})
    virtual_machine_scale_sets = optional(map(any), {})
    aks_clusters               = optional(map(any), {})
    cosmos_dbs                 = optional(map(any), {})
    redis_caches               = optional(map(any), {})
    managed_redis              = optional(map(any), {})
    linux_web_apps             = optional(map(any), {})
    windows_web_apps           = optional(map(any), {})
    network_security_groups    = optional(map(any), {})
    azurerm_firewalls          = optional(map(any), {})
    keyvaults                  = optional(map(any), {})
    servicebus_namespaces      = optional(map(any), {})
    event_hub_namespaces       = optional(map(any), {})
    load_tests                 = optional(map(any), {})

  })
  default = {}
}
