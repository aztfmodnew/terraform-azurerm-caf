variable "settings" {
  description = <<DESCRIPTION
  Settings object for the PIM eligible assignment schedule. Configuration attributes:
    - name              - (Required) Logical name/key for this schedule instance within the module.
    - scope             - (Required) Scope at which the role is eligible (e.g., subscription, resource group, or resource ID).
    - role_definition_id - (Required) The full resource ID of the role definition to assign eligibility for.
    - principal_id      - (Optional) Object ID of the principal. Exactly one of principal_id, managed_identity, or azuread_group must be provided. Resolution order: principal_id → managed_identity → azuread_group.
    - managed_identity  - (Optional) Key-based reference to a managed identity. Mutually exclusive with principal_id and azuread_group.
        - key    - (Required) Key of the managed identity in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - azuread_group     - (Optional) Key-based reference to an Azure AD group. Mutually exclusive with principal_id and managed_identity.
        - key    - (Required) Key of the Azure AD group in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - justification     - (Optional) Justification for the eligible assignment.
    - start_date        - (Optional) Start date/time for the eligibility in ISO 8601 format (flat; prefer schedule.start_date_time — nested takes precedence).
    - end_date          - (Optional) End date/time in ISO 8601 format (flat; prefer schedule.expiration.end_date_time — nested takes precedence).
    - start_date_time   - (Optional) Alias for start_date in ISO 8601 format.
    - end_date_time     - (Optional) Alias for end_date in ISO 8601 format.
    - duration_days     - (Optional) Days the assignment is eligible (flat; prefer schedule.expiration.duration_days — nested takes precedence).
    - duration_hours    - (Optional) Hours the assignment is eligible (flat; prefer schedule.expiration.duration_hours — nested takes precedence).
    - ticket_number     - (Optional) External ticket number (flat; prefer ticket.number — nested takes precedence).
    - ticket_system     - (Optional) External ticketing system (flat; prefer ticket.system — nested takes precedence).
    - schedule          - (Optional) Nested schedule configuration (preferred over flat fields). Attributes:
        - start_date_time  - (Optional) The ISO 8601 timestamp when the assignment becomes eligible.
        - expiration       - (Optional) Expiration configuration. Specify only one of duration_days, duration_hours, or end_date_time. Attributes:
            - duration_days  - (Optional) Number of days the assignment is eligible.
            - duration_hours - (Optional) Number of hours the assignment is eligible.
            - end_date_time  - (Optional) The ISO 8601 timestamp when the assignment expires.
    - ticket            - (Optional) Nested ticketing configuration (preferred over flat fields). Attributes:
        - number - (Optional) Ticket number or identifier.
        - system - (Optional) Name of the external ticketing system.
    - timeouts          - (Optional) Terraform operation timeouts. Attributes:
        - create - (Optional) Timeout for create operations (e.g., "30m").
        - read   - (Optional) Timeout for read operations.
        - delete - (Optional) Timeout for delete operations.
  DESCRIPTION

  type = object({
    name               = string
    scope              = string
    role_definition_id = string
    principal_id       = optional(string)
    justification      = optional(string)

    managed_identity = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    azuread_group = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    # Flat date/duration fields (legacy; prefer nested schedule block)
    start_date     = optional(string)
    end_date       = optional(string)
    start_date_time = optional(string)
    end_date_time  = optional(string)
    duration_days  = optional(number)
    duration_hours = optional(number)

    # Flat ticket fields (legacy; prefer nested ticket block)
    ticket_number = optional(string)
    ticket_system = optional(string)

    # Nested schedule block (preferred)
    schedule = optional(object({
      start_date_time = optional(string)
      expiration = optional(object({
        duration_days  = optional(number)
        duration_hours = optional(number)
        end_date_time  = optional(string)
      }))
    }))

    # Nested ticket block (preferred)
    ticket = optional(object({
      number = optional(string)
      system = optional(string)
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
        "role_definition_id",
        "principal_id",
        "managed_identity",
        "azuread_group",
        "justification",
        "start_date",
        "end_date",
        "start_date_time",
        "end_date_time",
        "duration_days",
        "duration_hours",
        "ticket_number",
        "ticket_system",
        "schedule",
        "ticket",
        "timeouts",
      ]
    )) == 0
    error_message = "Unsupported attributes in settings. Allowed: name, scope, role_definition_id, principal_id, managed_identity, azuread_group, justification, start_date, end_date, start_date_time, end_date_time, duration_days, duration_hours, ticket_number, ticket_system, schedule, ticket, timeouts."
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
