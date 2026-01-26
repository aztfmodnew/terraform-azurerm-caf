output "id" {
  description = "The ID of the Chaos Studio Experiment"
  value       = azurerm_chaos_studio_experiment.experiment.id
}

output "name" {
  description = "The name of the Chaos Studio Experiment"
  value       = azurerm_chaos_studio_experiment.experiment.name
}

output "location" {
  description = "The Azure region of the Chaos Studio Experiment"
  value       = azurerm_chaos_studio_experiment.experiment.location
}

output "resource_group_name" {
  description = "The resource group name"
  value       = azurerm_chaos_studio_experiment.experiment.resource_group_name
}

output "identity" {
  description = "The identity block of the experiment"
  value       = try(azurerm_chaos_studio_experiment.experiment.identity, null)
}

output "principal_id" {
  description = "The principal ID of the managed identity"
  value       = try(azurerm_chaos_studio_experiment.experiment.identity[0].principal_id, null)
}
