variable "settings" {
  description = <<DESCRIPTION
  Settings object for the PIM eligible assignment schedule. Configuration attributes:
    - name                  - (Required) Logical name/key for this schedule instance within the module.
    - scope                 - (Required) Scope at which the role is eligible (e.g., subscription, resource group, or resource ID).
    - role_definition_id   - (Required) The full resource ID of the role definition to assign eligibility for (e.g., "/subscriptions/.../providers/Microsoft.Authorization/roleDefinitions/...").
    - principal_id         - (Required) Object ID of the principal (user, group, or service principal) to make eligible.
    - justification         - (Optional) Justification for the eligible assignment.
    - start_date            - (Optional) Start date/time for the eligibility in ISO 8601 format. If omitted, eligibility starts immediately.
    - end_date              - (Optional) End date/time for the eligibility in ISO 8601 format. If omitted, eligibility does not expire unless expiration is defined separately.
    - ticket_number         - (Optional) External ticket number related to this assignment (for example, an incident or change ticket ID).
    - ticket_system         - (Optional) Name of the external ticketing system.
    - permanent             - (Optional) Whether the assignment is permanent. Defaults to false when not specified.
    - tags                  - (Optional) Tags to associate with this schedule instance for tracking and governance.
  DESCRIPTION

  type = object({
    name                 = string
    scope                = string
    role_definition_id   = string
    principal_id         = string
    justification        = optional(string)
    start_date           = optional(string)
    end_date             = optional(string)
    ticket_number        = optional(string)
    ticket_system        = optional(string)
    permanent            = optional(bool)
    tags                 = optional(map(string))
  })

  validation {
    condition = length(setsubtract(
      keys(var.settings),
      [
        "name",
        "scope",
        "role_definition_id",
        "principal_id",
        "justification",
        "start_date",
        "end_date",
        "ticket_number",
        "ticket_system",
        "permanent",
        "tags"
      ]
    )) == 0
    error_message = "Unsupported attributes in settings. Allowed attributes are: name, scope, role_definition_id, principal_id, justification, start_date, end_date, ticket_number, ticket_system, permanent, tags."
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
