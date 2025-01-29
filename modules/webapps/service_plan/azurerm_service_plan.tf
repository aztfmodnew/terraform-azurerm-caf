resource "azurerm_service_plan" "sp" {
  name                = azurecaf_name.plan.result
  location            = local.location
  os_type             = try(var.settings.os_type, null)
  resource_group_name = local.resource_group_name
  sku_name            = var.settings.sku_name
  app_service_environment_id = try(
    var.settings.app_service_environment_id,
    var.remote_objects.app_service_environments_v3[try(var.settings.app_service_environment_v3.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_environment_v3.key, var.settings.app_service_environment_v3_key)].id,
    var.remote_objects.app_service_environments[try(var.settings.app_service_environment.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_environment.key, var.settings.app_service_environment_key)].id,
    null
  )
  maximum_elastic_worker_count = try(var.settings.maximum_elastic_worker_count, null)
  worker_count                 = try(var.settings.worker_count, null)
  per_site_scaling_enabled     = try(var.settings.per_site_scaling_enabled, null)
  zone_balancing_enabled       = try(var.settings.zone_balancing_enabled, null)
  tags                         = local.tags

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, [])
    content {
      create = try(timeouts.create, null)
      read   = try(timeouts.read, null)
      update = try(timeouts.update, null)
      delete = try(timeouts.delete, null)
    }
  }


  /* Delete this block if not needed
 
  lifecycle {
    # TEMP until native tf provider for ASE ready to avoid force replacement of asp on every ase changes
    ignore_changes = [app_service_environment_id]
  }*/
}


