variable "settings" {
  description = <<DESCRIPTION
  Settings object for Entra ID PIM for groups assignment schedules. Configuration attributes:
    - assignment_mode      - (Required) Target schedule type. Allowed values: "active", "eligible".
    - assignment_type      - (Required) Group assignment type. Allowed values: "member", "owner".
    - group_id             - (Optional) Object ID of the target privileged access group.
    - group                - (Optional) Key-based or standalone selector for target group. Used when group_id is not provided.
      - key                - (Optional) Key in remote_objects.azuread_groups.
      - display_name       - (Optional) Display name for standalone lookup.
      - lz_key             - (Optional) Landing zone key for cross-LZ references.
    - principal_id         - (Optional) Object ID of the principal to assign.
    - principal_group      - (Optional) Key-based or standalone selector for principal group. Used when principal_id is not provided.
      - key                - (Optional) Key in remote_objects.azuread_groups.
      - display_name       - (Optional) Display name for standalone lookup.
      - lz_key             - (Optional) Landing zone key for cross-LZ references.
    - principal_user       - (Optional) Key-based or standalone selector for principal user. Used when principal_id and principal_group are not provided.
      - key                - (Optional) Key in remote_objects.azuread_users.
      - user_principal_name - (Optional) UPN for standalone lookup.
      - lz_key             - (Optional) Landing zone key for cross-LZ references.
    - justification        - (Optional) Justification for the assignment request.
    - ticket_number        - (Optional) Ticket number associated with the assignment request.
    - ticket_system        - (Optional) Ticketing system associated with ticket_number.
    - start_date           - (Optional) Assignment start date in RFC3339 format.
    - expiration_date      - (Optional) Assignment expiration date in RFC3339 format.
    - duration             - (Optional) Assignment duration in ISO8601 duration format (for example, "P30D" or "PT3H").
    - permanent_assignment - (Optional) Whether the assignment is permanent.
    - timeouts             - (Optional) Terraform operation timeouts.
      - create             - (Optional) Timeout for create operations.
      - read               - (Optional) Timeout for read operations.
      - update             - (Optional) Timeout for update operations.
      - delete             - (Optional) Timeout for delete operations.

  One of expiration_date, duration, or permanent_assignment must be provided.
  DESCRIPTION

  type = object({
    assignment_mode      = string
    assignment_type      = string
    group_id             = optional(string)
    principal_id         = optional(string)
    justification        = optional(string)
    ticket_number        = optional(string)
    ticket_system        = optional(string)
    start_date           = optional(string)
    expiration_date      = optional(string)
    duration             = optional(string)
    permanent_assignment = optional(bool)

    group = optional(object({
      key          = optional(string)
      display_name = optional(string)
      lz_key       = optional(string)
    }))

    principal_group = optional(object({
      key          = optional(string)
      display_name = optional(string)
      lz_key       = optional(string)
    }))

    principal_user = optional(object({
      key                 = optional(string)
      user_principal_name = optional(string)
      lz_key              = optional(string)
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
        "assignment_mode",
        "assignment_type",
        "group_id",
        "group",
        "principal_id",
        "principal_group",
        "principal_user",
        "justification",
        "ticket_number",
        "ticket_system",
        "start_date",
        "expiration_date",
        "duration",
        "permanent_assignment",
        "timeouts"
      ]
    )) == 0

    error_message = "Unsupported attributes in settings. Allowed: assignment_mode, assignment_type, group_id, group, principal_id, principal_group, principal_user, justification, ticket_number, ticket_system, start_date, expiration_date, duration, permanent_assignment, timeouts."
  }

  validation {
    condition     = contains(["active", "eligible"], lower(var.settings.assignment_mode))
    error_message = "settings.assignment_mode must be one of: active, eligible."
  }

  validation {
    condition     = contains(["member", "owner"], lower(var.settings.assignment_type))
    error_message = "settings.assignment_type must be one of: member, owner."
  }

  validation {
    condition = (
      var.settings.group_id != null ||
      try(var.settings.group.key, null) != null ||
      try(var.settings.group.display_name, null) != null
    )
    error_message = "One of group_id or group (key/display_name) must be provided."
  }

  validation {
    condition = (
      var.settings.principal_id != null ||
      try(var.settings.principal_group.key, null) != null ||
      try(var.settings.principal_group.display_name, null) != null ||
      try(var.settings.principal_user.key, null) != null ||
      try(var.settings.principal_user.user_principal_name, null) != null
    )
    error_message = "One of principal_id, principal_group, or principal_user must be provided."
  }

  validation {
    condition = (
      var.settings.expiration_date != null ||
      var.settings.duration != null ||
      try(var.settings.permanent_assignment, null) != null
    )
    error_message = "One of expiration_date, duration, or permanent_assignment must be provided."
  }
}

variable "global_settings" {
  description = "Global settings object (see module README.md)."
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
