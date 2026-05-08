variable "settings" {
  description = <<DESCRIPTION
  Settings object for a PIM eligible role assignment. Configuration attributes:
    - name                 - (Optional) Friendly name for this eligible role assignment instance.
    - scope                - (Optional) The scope at which the role is assigned (e.g., subscription or resource group ID).
    - scope_management_group - (Optional) Key-based reference to a management group whose ID will be used as scope. Mutually exclusive with scope and scope_subscription.
      - key    - (Required) Key of the management group in the combined_objects map.
      - lz_key - (Optional) Landing zone key for cross-LZ references.
    - scope_subscription   - (Optional) Key-based reference to a subscription whose ID will be used as scope. Mutually exclusive with scope and scope_management_group.
      - key    - (Required) Key of the subscription in the combined_objects map.
      - lz_key - (Optional) Landing zone key for cross-LZ references.
    - principal_id         - (Optional) Object ID of the principal. Exactly one of principal_id, managed_identity, or azuread_group must be provided. Resolution order: principal_id → managed_identity → azuread_group.
    - managed_identity     - (Optional) Key-based reference to a managed identity whose principal_id will be used. Mutually exclusive with principal_id and azuread_group.
        - key    - (Required) Key of the managed identity in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - azuread_group        - (Optional) Key-based reference to an Azure AD group whose object_id will be used. Mutually exclusive with principal_id and managed_identity.
        - key    - (Required) Key of the Azure AD group in the combined_objects map.
        - lz_key - (Optional) Landing zone key for cross-LZ references.
    - role_definition_id   - (Optional) The full resource ID of the role definition to use.
    - role_definition      - (Optional) Key-based reference to a role definition entry whose ID will be used. Mutually exclusive with role_definition_id.
      - key    - (Required) Key of the role definition in the combined_objects map.
      - lz_key - (Optional) Landing zone key for cross-LZ references.
    - justification        - (Optional) Justification text associated with the PIM eligible assignment.
    - condition            - (Optional) An ABAC condition expression applied to the role assignment. Requires condition_version.
    - condition_version    - (Optional) Version of the condition expression syntax. Currently only "2.0" is supported.
    - ticket               - (Optional) Ticketing information associated with the PIM request. Attributes:
        - number - (Optional) Ticket number or identifier in the external system.
        - system - (Optional) Name or key of the external ticketing system (e.g., ServiceNow).
    - schedule             - (Optional) Schedule configuration for the eligible assignment. Specify only one of duration_days, duration_hours, or end_date_time within expiration. Attributes:
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
    scope              = optional(string)
    principal_id       = optional(string)
    role_definition_id = optional(string)
    justification      = optional(string)
    condition          = optional(string)
    condition_version  = optional(string)

    scope_management_group = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    scope_subscription = optional(object({
      key    = string
      lz_key = optional(string)
    }))

    role_definition = optional(object({
      key    = string
      lz_key = optional(string)
    }))

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
        "scope_management_group",
        "scope_subscription",
        "principal_id",
        "managed_identity",
        "azuread_group",
        "role_definition_id",
        "role_definition",
        "justification",
        "condition",
        "condition_version",
        "ticket",
        "schedule",
        "timeouts",
      ]
    )) == 0

    error_message = "Unsupported attributes in settings. Allowed: name, scope, scope_management_group, scope_subscription, principal_id, managed_identity, azuread_group, role_definition_id, role_definition, justification, condition, condition_version, ticket, schedule, timeouts."
  }

  validation {
    condition = (
      var.settings.scope != null ||
      try(var.settings.scope_management_group.key, null) != null ||
      try(var.settings.scope_subscription.key, null) != null
    )
    error_message = "One of scope, scope_management_group, or scope_subscription must be provided."
  }

  validation {
    condition = (
      var.settings.role_definition_id != null ||
      try(var.settings.role_definition.key, null) != null
    )
    error_message = "One of role_definition_id or role_definition must be provided."
  }

  validation {
    condition = (
      var.settings.principal_id != null ||
      try(var.settings.managed_identity.key, null) != null ||
      try(var.settings.azuread_group.key, null) != null
    )
    error_message = "One of principal_id, managed_identity, or azuread_group must be provided."
  }

  validation {
    condition = (
      (var.settings.condition == null && var.settings.condition_version == null) ||
      (var.settings.condition != null && var.settings.condition_version != null)
    )
    error_message = "condition and condition_version must be provided together."
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
