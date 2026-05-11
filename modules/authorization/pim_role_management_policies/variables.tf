variable "settings" {
  description = <<DESCRIPTION
  Settings object for a PIM Role Management Policy. Configuration attributes:
    - scope - (Optional) Full scope ID where the policy applies.
    - scope_management_group - (Optional) Key-based reference to management group scope.
      - key - (Required) Management group key.
      - lz_key - (Optional) Landing zone key.
    - scope_subscription - (Optional) Key-based reference to subscription scope.
      - key - (Required) Subscription key.
      - lz_key - (Optional) Landing zone key.
    - role_definition_id - (Optional) Full role definition resource ID.
    - role_definition - (Optional) Key-based reference to role definition object.
      - key - (Required) Role definition key.
      - lz_key - (Optional) Landing zone key.
    - activation_rules - (Optional) Activation rules object.
      - maximum_duration - (Optional) ISO8601 duration.
      - require_approval - (Optional) Require approval.
      - require_justification - (Optional) Require justification.
      - require_multifactor_authentication - (Optional) Require MFA.
      - require_ticket_info - (Optional) Require ticketing information.
      - required_conditional_access_authentication_context - (Optional) Conditional access auth context.
      - approval_stage - (Optional) Approval stage configuration.
        - primary_approver - (Optional) List of primary approvers.
          - object_id - (Required) Object ID.
          - type - (Required) Principal type.
    - active_assignment_rules - (Optional) Active assignment rules.
      - expiration_required - (Optional) If false, permanent active assignments are permitted by policy.
      - expire_after - (Optional) ISO8601 maximum duration.
      - require_justification - (Optional) Require justification.
      - require_multifactor_authentication - (Optional) Require MFA.
      - require_ticket_info - (Optional) Require ticketing information.
    - eligible_assignment_rules - (Optional) Eligible assignment rules.
      - expiration_required - (Optional) If false, permanent eligible assignments are permitted by policy.
      - expire_after - (Optional) ISO8601 maximum duration.
    - notification_rules - (Optional) Notification rules for active assignments, eligible activations, and eligible assignments.
      - <category>.<recipient_group>_notifications.default_recipients - (Required) Notify default recipients.
      - <category>.<recipient_group>_notifications.notification_level - (Required) Notification level.
      - <category>.<recipient_group>_notifications.additional_recipients - (Optional) Additional email recipients.
    - timeouts - (Optional) Terraform operation timeouts.
      - create/read/update/delete - (Optional) Timeout strings.
  DESCRIPTION

  type = object({
    scope              = optional(string)
    role_definition_id = optional(string)

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

    activation_rules = optional(object({
      maximum_duration                                   = optional(string)
      require_approval                                   = optional(bool)
      require_justification                              = optional(bool)
      require_multifactor_authentication                 = optional(bool)
      require_ticket_info                                = optional(bool)
      required_conditional_access_authentication_context = optional(string)
      approval_stage = optional(object({
        primary_approver = optional(list(object({
          object_id = string
          type      = string
        })))
      }))
    }))

    active_assignment_rules = optional(object({
      expiration_required                = optional(bool)
      expire_after                       = optional(string)
      require_justification              = optional(bool)
      require_multifactor_authentication = optional(bool)
      require_ticket_info                = optional(bool)
    }))

    eligible_assignment_rules = optional(object({
      expiration_required = optional(bool)
      expire_after        = optional(string)
    }))

    notification_rules = optional(object({
      active_assignments = optional(object({
        admin_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
        approver_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
        assignee_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
      }))
      eligible_activations = optional(object({
        admin_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
        approver_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
        assignee_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
      }))
      eligible_assignments = optional(object({
        admin_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
        approver_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
        assignee_notifications = optional(object({
          additional_recipients = optional(list(string))
          default_recipients    = bool
          notification_level    = string
        }))
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
        "scope",
        "scope_management_group",
        "scope_subscription",
        "role_definition_id",
        "role_definition",
        "activation_rules",
        "active_assignment_rules",
        "eligible_assignment_rules",
        "notification_rules",
        "timeouts"
      ]
    )) == 0

    error_message = "Unsupported attributes in settings. Allowed: scope, scope_management_group, scope_subscription, role_definition_id, role_definition, activation_rules, active_assignment_rules, eligible_assignment_rules, notification_rules, timeouts."
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
