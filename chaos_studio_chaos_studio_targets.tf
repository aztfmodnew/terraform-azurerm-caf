module "chaos_studio_targets" {
  source   = "./modules/chaos_studio/chaos_studio_target"
  for_each = local.chaos_studio.chaos_studio_targets

  depends_on = [
    module.storage_accounts,
    module.virtual_machines,
    module.virtual_machine_scale_sets,
    module.aks_clusters,
    module.cosmos_dbs,
    module.redis_caches,
    module.managed_redis,
    module.linux_web_apps,
    module.windows_web_apps,
    module.network_security_groups,
    module.azurerm_firewalls,
    module.keyvaults,
    module.servicebus_namespaces,
    module.event_hub_namespaces
  ]

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    resource_groups            = local.combined_objects_resource_groups
    storage_accounts           = local.combined_objects_storage_accounts
    virtual_machines           = local.combined_objects_virtual_machines
    virtual_machine_scale_sets = local.combined_objects_virtual_machine_scale_sets
    aks_clusters               = local.combined_objects_aks_clusters
    cosmos_dbs                 = local.combined_objects_cosmos_dbs
    redis_caches               = local.combined_objects_redis_caches
    managed_redis              = local.combined_objects_managed_redis
    linux_web_apps             = local.combined_objects_linux_web_apps
    windows_web_apps           = local.combined_objects_windows_web_apps
    network_security_groups    = local.combined_objects_network_security_groups
    azurerm_firewalls          = local.combined_objects_azurerm_firewalls
    keyvaults                  = local.combined_objects_keyvaults
    servicebus_namespaces      = local.combined_objects_servicebus_namespaces
    event_hub_namespaces       = local.combined_objects_event_hub_namespaces
    load_tests                 = local.combined_objects_load_test
  }
}

output "chaos_studio_targets" {
  value = module.chaos_studio_targets
}
