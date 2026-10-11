variable "global_settings" {
  description = "Global CAF naming settings."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings for an Azure Synapse SQL pool.

Required:
  - name - Input name used by CAF naming.

Optional:
  - sku_name - SQL pool DW compute SKU; defaults to DW100c.
  - storage_account_type - Backup storage redundancy, either LRS or GRS; defaults to GRS.
  - create_mode - Pool creation mode: Default, Recovery, or PointInTimeRestore. Defaults to Default.
  - collation - SQL collation, only used with Default creation mode.
  - data_encrypted - Enables transparent data encryption.
  - recovery_database_id - Source database ID, only used with Recovery creation mode.
  - restore - Point-in-time restore source and timestamp, only used with PointInTimeRestore creation mode.
  - geo_backup_policy_enabled - Enables geo-backup policy; defaults to true.
  - tags - Additional tags applied to the SQL pool.
  - timeouts - Create, read, update, and delete operation timeouts.
DESCRIPTION
  type = object({
    name                 = string
    sku_name             = optional(string, "DW100c")
    storage_account_type = optional(string, "GRS")
    create_mode          = optional(string, "Default")
    collation            = optional(string)
    data_encrypted       = optional(bool)
    recovery_database_id = optional(string)
    restore = optional(object({
      point_in_time      = string
      source_database_id = string
    }))
    geo_backup_policy_enabled = optional(bool, true)
    tags                      = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = contains(
      ["DW100c", "DW200c", "DW300c", "DW400c", "DW500c", "DW1000c", "DW1500c", "DW2000c", "DW2500c", "DW3000c", "DW5000c", "DW6000c", "DW7500c", "DW10000c", "DW15000c", "DW30000c"],
      var.settings.sku_name
    )
    error_message = "sku_name must be one of the supported Synapse SQL pool DW SKUs."
  }

  validation {
    condition     = contains(["LRS", "GRS"], var.settings.storage_account_type)
    error_message = "storage_account_type must be LRS or GRS."
  }

  validation {
    condition = (
      contains(["Default", "Recovery", "PointInTimeRestore"], var.settings.create_mode) &&
      (var.settings.create_mode == "PointInTimeRestore") == (try(var.settings.restore, null) != null) &&
      (var.settings.create_mode == "Recovery") == (try(var.settings.recovery_database_id, null) != null)
    )
    error_message = "create_mode must be Default, Recovery, or PointInTimeRestore; Recovery requires recovery_database_id and PointInTimeRestore requires restore."
  }
}

variable "synapse_workspace_id" {
  description = "ID of the parent Synapse workspace."
  type        = string
}

variable "tags" {
  description = "Inherited tags to apply to the SQL pool."
  type        = map(any)
}
