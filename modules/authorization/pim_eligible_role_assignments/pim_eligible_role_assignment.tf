# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/pim_eligible_role_assignment

resource "azurerm_pim_eligible_role_assignment" "pim_eligible_role_assignment" {
  scope              = var.settings.scope
  role_definition_id = var.settings.role_definition_id
  principal_id       = var.settings.principal_id

  dynamic "schedule" {
    for_each = try(var.settings.schedule, null) != null ? [var.settings.schedule] : []
    content {
      dynamic "expiration" {
        for_each = try(schedule.value.expiration, null) != null ? [schedule.value.expiration] : []
        content {
          duration_days  = try(expiration.value.duration_days, null)
          duration_hours = try(expiration.value.duration_hours, null)
          end_date_time  = try(expiration.value.end_date_time, null)
        }
      }
      start_date_time = try(schedule.value.start_date_time, null)
    }
  }

  justification = try(var.settings.justification, null)

  dynamic "ticket" {
    for_each = try(var.settings.ticket, null) != null ? [var.settings.ticket] : []
    content {
      number = try(ticket.value.number, null)
      system = try(ticket.value.system, null)
    }
  }
}
