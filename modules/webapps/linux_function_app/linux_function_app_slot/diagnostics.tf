module "diagnostics" {
  source            = "../../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_linux_function_app_slot.linux_function_app_slot.id
  resource_location = local.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
