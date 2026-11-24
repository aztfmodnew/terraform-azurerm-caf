module "api_center" {
  source   = "./modules/integration/api_center"
  for_each = local.integration.api_center

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags ? coalesce(local.global_settings.tags, {}) : {}

  remote_objects = {
    api_centers        = merge(lookup(var.remote_objects, "api_center", {}), lookup(var.remote_objects, "api_centers", {}))
    resource_groups    = local.combined_objects_resource_groups
    managed_identities = local.combined_objects_managed_identities
  }
}

output "api_center" {
  description = "Business-keyed API Center compositions created by this landing zone."
  value       = module.api_center
}
