# Terraform azurerm resource: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/pim_eligible_role_assignment

resource "azurerm_pim_eligible_role_assignment" "this" {
  scope              = local.scope
  role_definition_id = local.role_definition_id
  principal_id       = local.principal_id
  justification      = try(var.settings.justification, null)
  condition          = try(var.settings.condition, null)
  condition_version  = try(var.settings.condition_version, null)

  dynamic "schedule" {
    for_each = try(var.settings.schedule, null) == null ? [] : [var.settings.schedule]

    content {
      start_date_time = try(schedule.value.start_date_time, null)

      dynamic "expiration" {
        for_each = try(schedule.value.expiration, null) == null ? [] : [schedule.value.expiration]

        content {
          duration_days  = try(expiration.value.duration_days, null)
          duration_hours = try(expiration.value.duration_hours, null)
          end_date_time  = try(expiration.value.end_date_time, null)
        }
      }
    }
  }

  dynamic "ticket" {
    for_each = try(var.settings.ticket, null) == null ? [] : [var.settings.ticket]

    content {
      number = try(ticket.value.number, null)
      system = try(ticket.value.system, null)
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
