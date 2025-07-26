output "id" {
  value       = azurerm_machine_learning_compute_instance.mlci.id
  description = "The ID of the Machine Learning Compute Instance."
}
output "identity" {
  value       = try(azurerm_machine_learning_compute_instance.mlci.identity, null)
  description = "An `identity` block as defined below, which contains the Managed Service Identity information for this Machine Learning Compute Instance."
}
output "ssh" {
  value       = azurerm_machine_learning_compute_instance.mlci.ssh
  description = "An `ssh` block as defined below, which specifies policy and settings for SSH access for this Machine Learning Compute Instance."
}
output "rbac_id" {
  value       = try(azurerm_machine_learning_compute_instance.mlci.identity[0].principal_id, null)
  description = "The rbac_id of the Machine Learning Compute Instance for role assignments."
}
# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
