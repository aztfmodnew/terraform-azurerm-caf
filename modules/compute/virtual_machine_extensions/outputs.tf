output "instance_view_statuses" {
  value       = data.azapi_resource_action.azurerm_virtual_machine_status.output.statuses
  description = "VM runtime statuses used to gate extension operations."
}
