output "id" {
  description = "The ID of the PIM Eligible Assignment Schedule."
  value       = azurerm_pim_eligible_role_assignment.pim_eligible_assignment_schedule.id
}

output "principal_type" {
  description = "The type of principal (User, Group, ServicePrincipal)."
  value       = azurerm_pim_eligible_role_assignment.pim_eligible_assignment_schedule.principal_type
}
