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
  target_resource_id = (
    var.settings.target_resource_id != null ? var.settings.target_resource_id :
    # Storage
    var.settings.target_type == "Microsoft-StorageAccount" ? try(var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id, null) :
    # Compute
    var.settings.target_type == "Microsoft-VirtualMachine" ? try(var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-VirtualMachineScaleSet" ? try(var.remote_objects.virtual_machine_scale_sets[local.lz_key][local.resource_key].id, null) :
    # Containers
    var.settings.target_type == "Microsoft-AzureKubernetesServiceChaosMesh" ? try(var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-ContainerService/managedClusters" ? try(var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id, null) :
    # Databases
    var.settings.target_type == "Microsoft-CosmosDB" ? try(var.remote_objects.cosmos_dbs[local.lz_key][local.resource_key].id, null) :
    # Cache
    var.settings.target_type == "Microsoft-AzureCacheForRedis" ? try(var.remote_objects.redis_caches[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-ManagedRedis" ? try(var.remote_objects.managed_redis[local.lz_key][local.resource_key].id, null) :
    # Web Apps
    var.settings.target_type == "Microsoft-AppService" ? try(coalesce(try(var.remote_objects.linux_web_apps[local.lz_key][local.resource_key].id, null), try(var.remote_objects.windows_web_apps[local.lz_key][local.resource_key].id, null)), null) :
    # Networking
    var.settings.target_type == "Microsoft-NetworkSecurityGroup" ? try(var.remote_objects.network_security_groups[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-Firewalls" ? try(var.remote_objects.azurerm_firewalls[local.lz_key][local.resource_key].id, null) :
    # Security & Management
    var.settings.target_type == "Microsoft-KeyVault" ? try(var.remote_objects.keyvaults[local.lz_key][local.resource_key].id, null) :
    # Messaging
    var.settings.target_type == "Microsoft-ServiceBus" ? try(var.remote_objects.servicebus_namespaces[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-EventHub" ? try(var.remote_objects.event_hub_namespaces[local.lz_key][local.resource_key].id, null) :
    # Load Testing
    var.settings.target_type == "Microsoft-AzureLoadTest" ? try(var.remote_objects.load_tests[local.lz_key][local.resource_key].id, null) :
    # Agent-based (requires Agent target type, no specific resource mapping)
    var.settings.target_type == "Microsoft-Agent" ? null :
    null
  )
}
