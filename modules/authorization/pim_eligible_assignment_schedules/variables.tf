variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for Azure PIM Eligible Assignment Schedule. Configuration attributes:
      - scope              - (Required) The scope at which the role assignment should be created.
      - role_definition_id - (Required) The role definition ID for the assignment.
      - principal_id       - (Required) The principal (user, group, or service principal) ID.
      - justification      - (Optional) The justification for the role assignment.
      - schedule           - (Required) Schedule block for time-bounded eligible assignments.
        - start_date_time  - (Optional) The start date/time of the assignment (RFC3339).
        - expiration       - (Optional) Expiration block.
          - duration_days  - (Optional) Duration in days.
          - duration_hours - (Optional) Duration in hours.
          - end_date_time  - (Optional) End date/time (RFC3339).
      - ticket             - (Optional) Ticket block for audit purposes.
        - number           - (Optional) The ticket number.
        - system           - (Optional) The ticket system name.
    DESCRIPTION
  type        = any
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
