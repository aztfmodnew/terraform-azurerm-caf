module "ai_services" {
  source   = "./modules/cognitive_services/ai_services"
  for_each = local.cognitive_services.ai_services

  client_config     = local.client_config
  global_settings   = local.global_settings
  resource_group    = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags         = local.global_settings.inherit_tags
  location          = try(each.value.location, null)
  settings          = each.value
  private_endpoints = try(each.value.private_endpoints, {})

  remote_objects = {
    storage_accounts   = local.combined_objects_storage_accounts
    managed_identities = local.combined_objects_managed_identities
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
    private_dns        = local.combined_objects_private_dns
    diagnostics        = local.combined_diagnostics
  }
}

output "ai_services" {
  value = module.ai_services
}

module "cognitive_account_project" {
  source   = "./modules/cognitive_services/cognitive_account_project"
  for_each = local.cognitive_services.cognitive_account_project

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  cognitive_account_id = coalesce(
    try(each.value.cognitive_account_id, null),
    try(each.value.cognitive_account.id, null),
    try(
      local.combined_objects_ai_services[
        try(each.value.cognitive_account.lz_key, local.client_config.landingzone_key)
      ][try(each.value.cognitive_account_key, each.value.cognitive_account.key)].id,
      null
    ),
    try(
      local.combined_objects_cognitive_services_accounts[
        try(each.value.cognitive_account.lz_key, local.client_config.landingzone_key)
      ][try(each.value.cognitive_account_key, each.value.cognitive_account.key)].id,
      null
    )
  )

  remote_objects = {
    managed_identities = local.combined_objects_managed_identities
  }
}

output "cognitive_account_project" {
  value = module.cognitive_account_project
}
