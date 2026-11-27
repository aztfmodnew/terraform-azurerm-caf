locals {
  resource_group  = var.resource_groups[try(var.settings.lz_key, var.settings.resource_group.lz_key, var.client_config.landingzone_key)][try(var.settings.resource_group.key, var.settings.resource_group_key)]
  storage_account = var.storage_accounts[try(var.settings.lz_key, var.settings.storage_account.lz_key, var.client_config.landingzone_key)][try(var.settings.storage_account.key, var.settings.storage_account_key)]
  service_plan    = var.service_plans[try(var.settings.service_plan.lz_key, var.settings.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)]
  app_settings = merge(
    try(var.app_settings, null) != null ? var.app_settings : {},
    local.dynamic_settings_to_process
  )
  dynamic_settings_to_process = {
    for setting in flatten([
      for setting_name, resources in try(var.settings.dynamic_app_settings, {}) : [
        for resource_type_key, resource in resources : [
          for object_id_key, object_attributes in resource : {
            key = setting_name
            value = try(
              var.combined_objects[resource_type_key][object_attributes.lz_key][object_id_key][object_attributes.attribute_key],
              var.combined_objects[resource_type_key][var.client_config.landingzone_key][object_id_key][object_attributes.attribute_key]
            )
          }
        ]
      ]
    ]) : setting.key => setting.value
  }
  #subnet_id        = can(var.settings.vnet_integration.subnet_id) || can(var.settings.vnet_integration.subnet_key) == false ? try(var.settings.vnet_integration.subnet_id, null) : var.subnets[try(var.settings.vnet_integration.lz_key, var.client_config.landingzone_key)][var.settings.vnet_integration.vnet_key].subnets[var.settings.vnet_integration.subnet_key].id
}

