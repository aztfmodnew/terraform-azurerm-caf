output "id" {
  value = coalesce(
    try(azuread_privileged_access_group_assignment_schedule.active[0].id, null),
    try(azuread_privileged_access_group_eligibility_schedule.eligible[0].id, null)
  )
}

output "status" {
  value = coalesce(
    try(azuread_privileged_access_group_assignment_schedule.active[0].status, null),
    try(azuread_privileged_access_group_eligibility_schedule.eligible[0].status, null)
  )
}

output "assignment_mode" {
  value = local.assignment_mode
}

output "group_id" {
  value = local.group_id
}

output "principal_id" {
  value = local.principal_id
}
