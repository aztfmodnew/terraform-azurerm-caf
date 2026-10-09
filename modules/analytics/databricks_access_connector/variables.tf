variable "name" {
  default = null
  type    = string
}
variable "settings" {
  description = <<DESCRIPTION
    Settings for an Azure Databricks access connector:
      - name - (Required) Resource name.
      - resource_group_key - (Optional) Key of the resource group in the current landing zone.
      - resource_group - (Optional) Resource group reference with key and optional lz_key.
      - lz_key - (Optional) Landing-zone key used with resource_group_key.
      - region - (Optional) Key in global_settings.regions. Defaults to the resource group's location.
      - identity - (Optional) Managed identity configuration. type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned. identity_ids accepts at most one user-assigned identity ID; managed_identity_keys and remote can resolve IDs from CAF managed identities.
      - tags - (Optional) Tags to assign to the access connector.
      - timeouts - (Optional) Create, read, update, and delete timeouts. Provider defaults are 30 minutes for create/update/delete and 5 minutes for read.
  DESCRIPTION
  type = object({
    name               = string
    resource_group_key = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
    }))
    lz_key = optional(string)
    region = optional(string)
    identity = optional(object({
      type                  = string
      identity_ids          = optional(list(string))
      managed_identity_keys = optional(list(string))
      remote = optional(map(object({
        managed_identity_keys = list(string)
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

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name",
      "resource_group_key",
      "resource_group",
      "lz_key",
      "region",
      "identity",
      "tags",
      "timeouts"
    ])) == 0
    error_message = "Unsupported access connector settings. Allowed attributes: name, resource_group_key, resource_group, lz_key, region, identity, tags, timeouts."
  }

  validation {
    condition = try(contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.settings.identity.type), true)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "resource_groups" {
  default = {}
  type    = map(any)
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "remote_objects" {
  type = any
}
