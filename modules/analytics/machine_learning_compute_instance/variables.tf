variable "global_settings" {
  description = "Global CAF naming settings."
  type        = any
}

variable "client_config" {
  description = "Client configuration, including landing-zone and tenant identifiers."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings for an Azure Machine Learning compute instance.

Required:
  - name - CAF input name used to generate the resource name.
  - virtual_machine_size - Azure VM size for the compute instance.

Optional:
  - machine_learning_workspace - Workspace reference with either id or key; lz_key
    selects a remote landing zone when key is used. The key reference is resolved by
    the CAF root module only; when calling this module directly, omit this attribute
    and pass the resolved workspace id through
    remote_objects.machine_learning_workspace_id.
  - region - Region key from global_settings.regions.
  - authorization_type - Supported value: personal.
  - assign_to_user - Optional personal user assignment (object_id and tenant_id).
  - description - Compute instance description.
  - identity - Managed identity type, direct identity_ids, or local/remote identity keys.
  - local_auth_enabled - Enables local authentication; defaults to true.
  - ssh - SSH settings containing a required RSA public_key.
  - subnet_resource_id - Direct subnet resource ID.
  - subnet - Subnet reference with either id, or both key and vnet_key, plus an
    optional lz_key. Key references are resolved by the CAF root module only; direct
    callers must pass subnet_resource_id or remote_objects.subnet_resource_id.
  - node_public_ip_enabled - Whether the instance has a public IP; defaults to true.
  - tags - Additional resource tags.
  - timeouts - Create, read, and delete operation timeouts.
DESCRIPTION
  type = object({
    name = string
    machine_learning_workspace = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    virtual_machine_size = string
    region               = optional(string)
    authorization_type   = optional(string)
    assign_to_user = optional(object({
      object_id = optional(string)
      tenant_id = optional(string)
    }))
    description = optional(string)
    identity = optional(object({
      type                  = string
      identity_ids          = optional(list(string))
      managed_identity_keys = optional(list(string), [])
      remote = optional(map(object({
        managed_identity_keys = optional(list(string), [])
      })), {})
    }))
    local_auth_enabled = optional(bool)
    ssh = optional(object({
      public_key = string
    }))
    subnet_resource_id = optional(string)
    subnet = optional(object({
      id       = optional(string)
      key      = optional(string)
      vnet_key = optional(string)
      lz_key   = optional(string)
    }))
    node_public_ip_enabled = optional(bool)
    tags                   = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = (
      try(var.settings.machine_learning_workspace, null) == null ||
      try(var.settings.machine_learning_workspace.id, null) != null ||
      try(var.settings.machine_learning_workspace.key, null) != null
    )
    error_message = "When machine_learning_workspace is supplied it must specify either id or key. Omit it entirely to use the resolved remote_objects.machine_learning_workspace_id."
  }

  validation {
    condition = (
      try(var.settings.subnet, null) == null ||
      try(var.settings.subnet.id, null) != null ||
      (
        try(var.settings.subnet.key, null) != null &&
        try(var.settings.subnet.vnet_key, null) != null
      )
    )
    error_message = "When subnet is supplied it must specify either id, or both key and vnet_key, otherwise the subnet silently resolves to null and the instance is created outside the intended network."
  }

  validation {
    condition = (
      try(var.settings.authorization_type, null) == null ||
      var.settings.authorization_type == "personal"
    )
    error_message = "authorization_type must be personal when specified."
  }

  validation {
    condition = (
      try(var.settings.identity.type, null) == null ||
      contains(
        ["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"],
        try(var.settings.identity.type, "")
      )
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition = (
      !contains(
        ["UserAssigned", "SystemAssigned, UserAssigned"],
        try(var.settings.identity.type, "")
      ) ||
      length(coalesce(try(var.settings.identity.identity_ids, null), [])) > 0 ||
      length(coalesce(try(var.settings.identity.managed_identity_keys, null), [])) > 0 ||
      length(flatten([
        for remote_identity in coalesce(try(var.settings.identity.remote, null), {}) :
        coalesce(try(remote_identity.managed_identity_keys, null), [])
      ])) > 0
    )
    error_message = "A user-assigned identity type requires identity_ids or managed identity keys."
  }
}

variable "remote_objects" {
  description = "Resolved workspace, subnet, and managed identity dependencies."
  type        = any
  default     = {}
}

variable "location" {
  description = "Azure location used for CAF resource naming."
  type        = string
}

variable "base_tags" {
  description = "Base tags inherited by this resource."
  type        = map(any)
  default     = {}
}
