module "custom_domains" {
  source   = "./custom_domain"
  for_each = try(var.settings.custom_domains, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    container_app = azurerm_container_app.ca
  })
}