module "linux_function_app_slot" {
  source   = "./linux_function_app_slot"
  for_each = try(var.settings.linux_function_app_slots, {})

  client_config   = var.client_config
  global_settings = var.global_settings
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  location        = var.location
  settings        = each.value

  remote_objects = {
    combined_objects = var.remote_objects.combined_objects
    diagnostics      = var.remote_objects.diagnostics
    keyvaults        = var.remote_objects.keyvaults
    storage_accounts = var.remote_objects.storage_accounts
    vnets            = var.remote_objects.vnets
    function_app_id  = azurerm_linux_function_app.linux_function_app.id
  }
}