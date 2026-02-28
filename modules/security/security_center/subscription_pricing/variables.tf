variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "base_tags" {
  description = "(Optional) Inherit tags from the resource group. Defaults to false."
  type        = bool
  default     = false
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for Azure Security Center Subscription Pricing. Configuration attributes:
      - tier          - (Required) Pricing tier. Possible values: Free, Standard.
      - resource_type - (Optional) Resource type affected. Defaults to VirtualMachines.
                        Possible values: AI, Api, AppServices, ContainerRegistry, KeyVaults,
                        KubernetesService, SqlServers, SqlServerVirtualMachines, StorageAccounts,
                        VirtualMachines, Arm, Dns, OpenSourceRelationalDatabases, Containers,
                        CosmosDbs, CloudPosture.
      - subplan       - (Optional) Subplan for the resource type. Forces new resource when changed.
      - extensions    - (Optional) Map of extension blocks.
        - name                            - (Required) Name of the extension.
        - additional_extension_properties - (Optional) Key/Value pairs for extension properties.
      - timeouts       - (Optional) Timeout overrides for create/read/update/delete.
    DESCRIPTION
  type = object({
    tier          = string
    resource_type = optional(string, "VirtualMachines")
    subplan       = optional(string)
    extensions = optional(map(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition     = contains(["Free", "Standard"], var.settings.tier)
    error_message = "settings.tier must be either 'Free' or 'Standard'."
  }
}
