variable "settings" {
  description = <<DESCRIPTION
  Settings object for the PIM active role assignment. Configuration attributes:
    - name - (Optional) Logical name/key for this PIM active role assignment instance.
    - enabled - (Optional) Whether to enable the assignment. If omitted, the module may default this to true.
    - scope - (Required) The scope at which the role should be assigned (e.g., subscription, resource group, or resource ID).
    - principal_id - (Optional) The object ID of the principal. Exactly one of principal_id, managed_identity, or azuread_group must be provided. Resolution order: principal_id → managed_identity → azuread_group.
    - managed_identity - (Optional) Key-based reference to a managed identity whose principal_id will be used. Mutually exclusive with principal_id and azuread_group.
        - key    - (Required) Key of the managed identity in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - azuread_group - (Optional) Key-based reference to an Azure AD group whose object_id will be used. Mutually exclusive with principal_id and managed_identity.
        - key    - (Required) Key of the Azure AD group in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - role_definition_id - (Optional) The ID of the role definition to assign. Either role_definition_id or role_definition_name is typically required.
    - role_definition_name - (Optional) The display name of the role definition to assign. Either role_definition_id or role_definition_name is typically required.
    - justification - (Optional) Justification text associated with the PIM active assignment request.
    - ticket - (Optional) Ticketing information associated with the PIM request. Attributes:
        - number - (Required) Ticket number or identifier in the external system.
        - system - (Required) Name or key of the external ticketing system (e.g., ServiceNow).
    - schedule - (Optional) Schedule configuration for the active assignment. Attributes:
        - start_date_time - (Optional) The ISO 8601 timestamp when the assignment becomes active.
        - expiration - (Optional) Expiration configuration for the assignment. Specify only one of duration_days, duration_hours, or end_date_time. Attributes:
            - duration_days  - (Optional) Number of days the assignment is active.
            - duration_hours - (Optional) Number of hours the assignment is active.
            - end_date_time  - (Optional) The ISO 8601 timestamp when the assignment expires.
    - timeouts - (Optional) Terraform operation timeouts for the underlying resource. Attributes:
        - create - (Optional) Timeout for create operations (e.g., "30m").
        - read   - (Optional) Timeout for read operations.
        - update - (Optional) Timeout for update operations.
        - delete - (Optional) Timeout for delete operations.
  DESCRIPTION

  type = object({
    name                 = optional(string)
    enabled              = optional(bool)
    scope                = string
    principal_id         = optional(string)
    role_definition_id   = optional(string)
    role_definition_name = optional(string)
    justification        = optional(string)

    managed_identity = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    azuread_group = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    ticket = optional(object({
      number = string
      system = string
    }))

    schedule = optional(object({
      start_date_time = optional(string)
      expiration = optional(object({
        duration_days  = optional(number)
        duration_hours = optional(number)
        end_date_time  = optional(string)
      }))
    }))

    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length(setsubtract(
      keys(var.settings),
      [
        "name",
        "enabled",
        "scope",
        "principal_id",
        "managed_identity",
        "azuread_group",
        "role_definition_id",
        "role_definition_name",
        "justification",
        "ticket",
        "schedule",
        "timeouts"
      ]
    )) == 0

    error_message = "Unsupported attributes in settings. Allowed attributes: name, enabled, scope, principal_id, managed_identity, azuread_group, role_definition_id, role_definition_name, justification, ticket, schedule, timeouts."
  }

  validation {
    condition = (
      var.settings.principal_id != null ||
      try(var.settings.managed_identity.key, null) != null ||
      try(var.settings.azuread_group.key, null) != null
    )
    error_message = "One of principal_id, managed_identity, or azuread_group must be provided."
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

variable "remote_objects" {
  description = "Remote objects for cross-module references"
  type        = any
  default     = {}
}
