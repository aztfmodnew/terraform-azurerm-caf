variable "settings" {
  description = <<DESCRIPTION
  Settings object for a PIM eligible role assignment. Configuration attributes:
    - name                       - (Optional) Friendly name for this eligible role assignment instance.
    - description                - (Optional) Description of the eligible assignment.
    - scope                      - (Optional) The scope at which the role is assigned (e.g., subscription or resource group ID).
    - principal_id               - (Optional) Object ID of the principal (user, group, or service principal) to assign the role to.
    - principal_type             - (Optional) Type of principal. Common values include "User", "Group", or "ServicePrincipal".
    - role_definition_id         - (Optional) The full resource ID of the role definition to use.
    - role_definition_name       - (Optional) The name of the role definition to use, if not specifying role_definition_id directly.
    - ticketing                  - (Optional) Additional ticketing or change-management metadata for the assignment. Arbitrary structure.
    - schedule                   - (Optional) Schedule configuration for the eligible assignment (activation rules, duration, etc.). Arbitrary structure.
    - justification_required     - (Optional) Whether justification is required when activating the eligible assignment.
    - mfa_on_activation_required - (Optional) Whether multi-factor authentication is required when activating the eligible assignment.
    - approval_required          - (Optional) Whether approval is required when activating the eligible assignment.
    - tags                       - (Optional) Tags to associate with resources created for this eligible assignment.
    - diagnostic_profiles        - (Optional) Diagnostic settings profiles configuration for this assignment, if applicable to the underlying resources.
  DESCRIPTION

  type = object({
    name                       = optional(string)
    description                = optional(string)
    scope                      = optional(string)
    principal_id               = optional(string)
    principal_type             = optional(string)
    role_definition_id         = optional(string)
    role_definition_name       = optional(string)
    ticketing                  = optional(any)
    schedule                   = optional(any)
    justification_required     = optional(bool)
    mfa_on_activation_required = optional(bool)
    approval_required          = optional(bool)
    tags                       = optional(map(string))
    diagnostic_profiles        = optional(map(any))
  })

  validation {
    condition = length(setsubtract(
      keys(var.settings),
      [
        "name",
        "description",
        "scope",
        "principal_id",
        "principal_type",
        "role_definition_id",
        "role_definition_name",
        "ticketing",
        "schedule",
        "justification_required",
        "mfa_on_activation_required",
        "approval_required",
        "tags",
        "diagnostic_profiles",
      ]
    )) == 0

    error_message = "Unsupported attributes in settings. Allowed: name, description, scope, principal_id, principal_type, role_definition_id, role_definition_name, ticketing, schedule, justification_required, mfa_on_activation_required, approval_required, tags, diagnostic_profiles."
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
