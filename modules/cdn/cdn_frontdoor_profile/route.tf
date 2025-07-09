module "routes" {
  source   = "./route"
  for_each = try(var.settings.routes, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_endpoints      = module.endpoints
    cdn_frontdoor_origin_groups  = module.origin_groups
    cdn_frontdoor_origins        = module.origins
    cdn_frontdoor_rule_sets      = module.rule_sets
    cdn_frontdoor_custom_domains = module.frontdoor_custom_domains
  })

  depends_on = [module.endpoints, module.origin_groups, module.origins, module.rule_sets]
}
