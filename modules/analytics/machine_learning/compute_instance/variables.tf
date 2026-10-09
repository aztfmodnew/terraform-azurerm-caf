variable "settings" {
  description = <<DESCRIPTION
Settings for the legacy ARM-template-backed Azure Machine Learning compute
instance. The ARM template inputs are computeInstanceName, vmSize,
adminUserName, sshAccess, and adminUserSshPublicKey. Optional AzureRM
deployment settings are debug_level, tags, and create/read/update/delete
timeouts.
DESCRIPTION
  type = object({
    computeInstanceName   = string
    vmSize                = string
    adminUserName         = string
    sshAccess             = string
    adminUserSshPublicKey = string
    debug_level           = optional(string)
    tags                  = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = (
      try(var.settings.debug_level, null) == null ||
      contains(
        ["none", "requestContent", "responseContent", "requestContent, responseContent"],
        coalesce(try(var.settings.debug_level, null), "none")
      )
    )
    error_message = "debug_level must be none, requestContent, responseContent, or requestContent, responseContent."
  }

  validation {
    condition     = contains(["Disabled", "Enabled"], var.settings.sshAccess)
    error_message = "sshAccess must be Disabled or Enabled."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "computeInstanceName",
      "vmSize",
      "adminUserName",
      "sshAccess",
      "adminUserSshPublicKey",
      "debug_level",
      "tags",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in settings. See the variable description for allowed attributes."
  }
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "machine_learning_workspace_name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "tags" {
  description = "(Required) Map of tags to be applied to the resource"
  type        = map(any)
}