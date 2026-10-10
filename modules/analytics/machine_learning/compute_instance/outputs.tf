output "id" {
  description = "The ID of the ARM template deployment that creates the legacy compute instance."
  value       = azurerm_resource_group_template_deployment.mlci.id
}

output "output_content" {
  description = "The JSON outputs returned by the ARM template deployment."
  value       = azurerm_resource_group_template_deployment.mlci.output_content
}
