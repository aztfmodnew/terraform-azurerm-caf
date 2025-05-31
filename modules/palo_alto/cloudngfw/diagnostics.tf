module "diagnostics" {
  source = "../../diagnostics" # Assuming diagnostics module is two levels up
  count  = local.diagnostics_enabled_for_ngfw ? 1 : 0

  resource_id       = local.actual_ngfw_resource_id             # Use the actual NGFW resource ID from locals
  resource_location = local.location                            # Use the location from the locals block
  diagnostics       = try(var.remote_objects.diagnostics, null) # Get diagnostics settings from remote_objects
  profiles          = var.settings.diagnostic_profiles
}
