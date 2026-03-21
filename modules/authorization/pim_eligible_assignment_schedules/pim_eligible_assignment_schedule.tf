# Terraform azurerm resource: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/pim_eligible_role_assignment
# Schedule-focused eligible role assignment for PIM

resource "azurerm_pim_eligible_role_assignment" "this" {
  scope              = var.settings.scope
  role_definition_id = var.settings.role_definition_id
  principal_id       = local.principal_id
  justification      = try(var.settings.justification, null)

  dynamic "schedule" {
    # Emit a schedule block if either a nested schedule object is provided
    # or if flat schedule fields (e.g. start_date, end_date) are set.
    for_each = (
      try(var.settings.schedule.start_date_time, null) != null ||
      try(var.settings.schedule.expiration, null) != null ||
      try(var.settings.start_date_time, null) != null ||
      try(var.settings.start_date, null) != null ||
      try(var.settings.end_date_time, null) != null ||
      try(var.settings.end_date, null) != null
    ) ? [1] : []

    content {
      # Prefer nested schedule.start_date_time; fall back to documented flat fields.
      start_date_time = try(
        var.settings.schedule.start_date_time,
        var.settings.start_date_time,
        var.settings.start_date,
        null
      )

      dynamic "expiration" {
        # Emit expiration if nested expiration is provided or flat duration/end_date fields exist.
        for_each = (
          try(var.settings.schedule.expiration, null) != null ||
          try(var.settings.duration_days, null) != null ||
          try(var.settings.duration_hours, null) != null ||
          try(var.settings.end_date_time, null) != null ||
          try(var.settings.end_date, null) != null
        ) ? [1] : []

        content {
          duration_days  = try(var.settings.schedule.expiration.duration_days, var.settings.duration_days, null)
          duration_hours = try(var.settings.schedule.expiration.duration_hours, var.settings.duration_hours, null)
          end_date_time  = try(
            var.settings.schedule.expiration.end_date_time,
            var.settings.end_date_time,
            var.settings.end_date,
            null
          )
        }
      }
    }
  }

  dynamic "ticket" {
    # Emit a ticket block if either a nested ticket object is provided
    # or if flat ticket fields (e.g. ticket_number, ticket_system) are set.
    for_each = (
      try(var.settings.ticket, null) != null ||
      try(var.settings.ticket_number, null) != null ||
      try(var.settings.ticket_system, null) != null
    ) ? [1] : []

    content {
      number = try(var.settings.ticket.number, var.settings.ticket_number, null)
      system = try(var.settings.ticket.system, var.settings.ticket_system, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}
