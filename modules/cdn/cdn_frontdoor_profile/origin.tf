module "origins" {
  source   = "./origin"
  for_each = try(var.settings.origins, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_origin_groups = module.origin_groups
  })

  depends_on = [module.origin_groups]
}
