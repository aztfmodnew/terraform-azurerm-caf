locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(
    var.base_tags ? var.global_settings.tags : {},
    local.module_tag,
    try(var.settings.tags, null)
  )

  location = coalesce(
    try(var.settings.location, null),
    var.location,
    var.resource_group.location
  )

  resource_group_name = coalesce(
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][try(var.settings.resource_group.key, var.settings.resource_group_key)].name, null)
  )

  # Resolve landing zone and resource keys
  lz_key       = coalesce(try(var.settings.target_resource.lz_key, null), var.client_config.landingzone_key)
  resource_key = try(var.settings.target_resource.key, var.settings.target_resource_key, null)

  # Resolve target_resource_id based on target_type using remote_objects
  # Supported target types: https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-providers
  # Use can() to safely check resource existence before accessing
  cosmos_db_id                 = can(var.remote_objects.cosmos_dbs[local.lz_key][local.resource_key].id) ? var.remote_objects.cosmos_dbs[local.lz_key][local.resource_key].id : null
  storage_account_id           = can(var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id) ? var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id : null
  virtual_machine_id           = can(var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id) ? var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id : null
  virtual_machine_scale_set_id = can(var.remote_objects.virtual_machine_scale_sets[local.lz_key][local.resource_key].id) ? var.remote_objects.virtual_machine_scale_sets[local.lz_key][local.resource_key].id : null
  aks_cluster_id               = can(var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id) ? var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id : null
  redis_cache_id               = can(var.remote_objects.redis_caches[local.lz_key][local.resource_key].id) ? var.remote_objects.redis_caches[local.lz_key][local.resource_key].id : null
  managed_redis_id             = can(var.remote_objects.managed_redis[local.lz_key][local.resource_key].id) ? var.remote_objects.managed_redis[local.lz_key][local.resource_key].id : null
  linux_web_app_id             = can(var.remote_objects.linux_web_apps[local.lz_key][local.resource_key].id) ? var.remote_objects.linux_web_apps[local.lz_key][local.resource_key].id : null
  windows_web_app_id           = can(var.remote_objects.windows_web_apps[local.lz_key][local.resource_key].id) ? var.remote_objects.windows_web_apps[local.lz_key][local.resource_key].id : null
  network_security_group_id    = can(var.remote_objects.network_security_groups[local.lz_key][local.resource_key].id) ? var.remote_objects.network_security_groups[local.lz_key][local.resource_key].id : null
  azurerm_firewall_id          = can(var.remote_objects.azurerm_firewalls[local.lz_key][local.resource_key].id) ? var.remote_objects.azurerm_firewalls[local.lz_key][local.resource_key].id : null
  keyvault_id                  = can(var.remote_objects.keyvaults[local.lz_key][local.resource_key].id) ? var.remote_objects.keyvaults[local.lz_key][local.resource_key].id : null
  servicebus_namespace_id      = can(var.remote_objects.servicebus_namespaces[local.lz_key][local.resource_key].id) ? var.remote_objects.servicebus_namespaces[local.lz_key][local.resource_key].id : null
  event_hub_namespace_id       = can(var.remote_objects.event_hub_namespaces[local.lz_key][local.resource_key].id) ? var.remote_objects.event_hub_namespaces[local.lz_key][local.resource_key].id : null
  load_test_id                 = can(var.remote_objects.load_tests[local.lz_key][local.resource_key].id) ? var.remote_objects.load_tests[local.lz_key][local.resource_key].id : null

  target_resource_id = try(var.settings.target_resource_id, null) != null ? var.settings.target_resource_id : (
    var.settings.target_type == "Microsoft-StorageAccount" ? local.storage_account_id :
    var.settings.target_type == "Microsoft-VirtualMachine" ? local.virtual_machine_id :
    var.settings.target_type == "Microsoft-VirtualMachineScaleSet" ? local.virtual_machine_scale_set_id :
    var.settings.target_type == "Microsoft-AzureKubernetesServiceChaosMesh" ? local.aks_cluster_id :
    var.settings.target_type == "Microsoft-ContainerService/managedClusters" ? local.aks_cluster_id :
    var.settings.target_type == "Microsoft-CosmosDB" ? local.cosmos_db_id :
    var.settings.target_type == "Microsoft-AzureCacheForRedis" ? local.redis_cache_id :
    var.settings.target_type == "Microsoft-ManagedRedis" ? local.managed_redis_id :
    var.settings.target_type == "Microsoft-AppService" ? coalesce(local.linux_web_app_id, local.windows_web_app_id) :
    var.settings.target_type == "Microsoft-NetworkSecurityGroup" ? local.network_security_group_id :
    var.settings.target_type == "Microsoft-Firewalls" ? local.azurerm_firewall_id :
    var.settings.target_type == "Microsoft-KeyVault" ? local.keyvault_id :
    var.settings.target_type == "Microsoft-ServiceBus" ? local.servicebus_namespace_id :
    var.settings.target_type == "Microsoft-EventHub" ? local.event_hub_namespace_id :
    var.settings.target_type == "Microsoft-AzureLoadTest" ? local.load_test_id :
    null
  )
}
