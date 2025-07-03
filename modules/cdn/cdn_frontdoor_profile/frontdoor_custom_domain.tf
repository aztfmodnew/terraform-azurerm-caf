# frontdoor_custom_domain.tf
# azurerm_cdn_frontdoor_custom_domain resource implementation

module "frontdoor_custom_domains" {
  source   = "./frontdoor_custom_domain"
  for_each = try(var.settings.frontdoor_custom_domains, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile  = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
    cdn_frontdoor_profiles = { "${var.client_config.landingzone_key}" = { "${local.profile_key}" = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile } }
  })
}