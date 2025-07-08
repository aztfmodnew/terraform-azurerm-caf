module "firewall_policies" {
  source   = "./firewall_policy"
  for_each = try(var.settings.firewall_policies, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
  })
}
