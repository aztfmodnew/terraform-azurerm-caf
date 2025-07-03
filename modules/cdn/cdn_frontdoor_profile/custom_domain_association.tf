# custom_domain_association.tf

module "custom_domain_associations" {
  source   = "./custom_domain_association"
  for_each = try(var.settings.custom_domain_associations, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_custom_domains = module.frontdoor_custom_domains
    cdn_frontdoor_routes         = module.routes
  })

  depends_on = [module.frontdoor_custom_domains, module.routes]
}
