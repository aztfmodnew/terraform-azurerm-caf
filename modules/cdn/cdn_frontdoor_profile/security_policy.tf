module "security_policies" {
  source   = "./security_policy"
  for_each = try(var.settings.security_policies, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile           = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
    cdn_frontdoor_firewall_policies = module.firewall_policies
    cdn_frontdoor_endpoints         = module.endpoints
  })

  depends_on = [module.firewall_policies, module.endpoints]
}
