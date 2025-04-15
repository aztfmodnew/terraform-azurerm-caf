module "slots" {
  source            = "./slots"
  for_each          = try(var.settings.slots, {})
  client_config     = var.client_config
  global_settings   = var.global_settings
  resource_group    = var.resource_group
  location          = local.location
  base_tags         = var.base_tags
  private_endpoints = try(each.value.private_endpoints, {})
  settings          = each.value

  remote_objects = {
    app_service_id   = azurerm_windows_web_app.windows_web_app.id
    vnets            = var.remote_objects.vnets
    storage_accounts = var.remote_objects.storage_accounts
  }
}


output "slots" {
  value = module.slots
}