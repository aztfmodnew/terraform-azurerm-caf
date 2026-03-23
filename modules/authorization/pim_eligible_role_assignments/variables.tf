variable "settings" {
  description = <<DESCRIPTION
  Settings object for a PIM eligible role assignment. Configuration attributes:
    - name                 - (Optional) Friendly name for this eligible role assignment instance.
    - scope                - (Required) The scope at which the role is assigned (e.g., subscription or resource group ID).
    - principal_id         - (Optional) Object ID of the principal. Required if managed_identity and azuread_group are not specified.
    - managed_identity     - (Optional) Key-based reference to a managed identity whose principal_id will be used. Attributes:
        - key    - (Required) Key of the managed identity in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - azuread_group        - (Optional) Key-based reference to an Azure AD group whose object_id will be used. Attributes:
        - key    - (Required) Key of the Azure AD group in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - role_definition_id   - (Required) The full resource ID of the role definition to use.
    - justification        - (Optional) Justification text associated with the PIM eligible assignment.
    - ticket               - (Optional) Ticketing information associated with the PIM request. Attributes:
        - number - (Optional) Ticket number or identifier in the external system.
        - system - (Optional) Name or key of the external ticketing system (e.g., ServiceNow).
    - schedule             - (Optional) Schedule configuration for the eligible assignment. Attributes:
        - start_date_time  - (Optional) The ISO 8601 timestamp when the assignment becomes eligible.
        - expiration       - (Optional) Expiration configuration. Attributes:
            - duration_days  - (Optional) Number of days the assignment is eligible.
            - duration_hours - (Optional) Number of hours the assignment is eligible.
            - end_date_time  - (Optional) The ISO 8601 timestamp when the assignment expires.
    - timeouts             - (Optional) Terraform operation timeouts. Attributes:
        - create - (Optional) Timeout for create operations (e.g., "30m").
        - read   - (Optional) Timeout for read operations.
        - delete - (Optional) Timeout for delete operations.
  DESCRIPTION

  type = object({
    name               = optional(string)
    scope              = string
    principal_id       = optional(string)
    role_definition_id = string
    justification      = optional(string)

    managed_identity = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    azuread_group = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    ticket = optional(object({
      number = optional(string)
      system = optional(string)
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
      delete = optional(string)
    }))
  })

  validation {
    condition = length(setsubtract(
      keys(var.settings),
      [
        "name",
        "scope",
        "principal_id",
        "managed_identity",
        "azuread_group",
        "role_definition_id",
        "justification",
        "ticket",
        "schedule",
        "timeouts",
      ]
    )) == 0

    error_message = "Unsupported attributes in settings. Allowed: name, scope, principal_id, managed_identity, azuread_group, role_definition_id, justification, ticket, schedule, timeouts."
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
