# Terraform resource docs:
# - https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_assignment_schedule
# - https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule

resource "azuread_privileged_access_group_assignment_schedule" "active" {
  count = local.assignment_mode == "active" ? 1 : 0

  group_id        = local.group_id
  principal_id    = local.principal_id
  assignment_type = lower(var.settings.assignment_type)
  justification   = try(var.settings.justification, null)
  ticket_number   = try(var.settings.ticket_number, null)
  ticket_system   = try(var.settings.ticket_system, null)
  start_date      = try(var.settings.start_date, null)
  expiration_date = try(var.settings.expiration_date, null)
  duration        = try(var.settings.duration, null)

  permanent_assignment = try(var.settings.permanent_assignment, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azuread_privileged_access_group_eligibility_schedule" "eligible" {
  count = local.assignment_mode == "eligible" ? 1 : 0

  group_id        = local.group_id
  principal_id    = local.principal_id
  assignment_type = lower(var.settings.assignment_type)
  justification   = try(var.settings.justification, null)
  ticket_number   = try(var.settings.ticket_number, null)
  ticket_system   = try(var.settings.ticket_system, null)
  start_date      = try(var.settings.start_date, null)
  expiration_date = try(var.settings.expiration_date, null)
  duration        = try(var.settings.duration, null)

  permanent_assignment = try(var.settings.permanent_assignment, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
