# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app

resource "azurerm_windows_function_app" "windows_function_app" {
  location            = local.location
  name                = azurecaf_name.windows_function_app.result
  resource_group_name = local.resource_group_name
  service_plan_id = coalesce(
    try(var.settings.service_plan_id, null),
    try(var.remote_objects.service_plans[try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null)
  )

  app_settings                             = try(local.app_settings, null)
  builtin_logging_enabled                  = try(var.settings.builtin_logging_enabled, true)
  client_certificate_enabled               = try(var.settings.client_certificate_enabled, null)
  client_certificate_mode                  = try(var.settings.client_certificate_mode, "Optional")
  client_certificate_exclusion_paths       = try(var.settings.client_certificate_exclusion_paths, null)
  content_share_force_disabled             = try(var.settings.content_share_force_disabled, false)
  daily_memory_time_quota                  = try(var.settings.daily_memory_time_quota, 0)
  enabled                                  = try(var.settings.enabled, true)
  ftp_publish_basic_authentication_enabled = try(var.settings.ftp_publish_basic_authentication_enabled, true)
  functions_extension_version              = try(var.settings.functions_extension_version, "~4")
  https_only                               = try(var.settings.https_only, false)
  public_network_access_enabled            = try(var.settings.public_network_access_enabled, true)
  key_vault_reference_identity_id = try(
    var.settings.key_vault_reference_identity_id,
    var.remote_objects.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][try(var.settings.key_vault_reference_identity.key, var.settings.key_vault_reference_identity_key)].id,
    null
  )

  site_config {
    always_on          = try(var.settings.site_config.always_on, false)
    api_definition_url = try(var.settings.site_config.api_definition_url, null)
    api_management_api_id = try(
      var.settings.site_config.api_management_api_id,
      var.remote_objects.api_management_apis[try(var.settings.site_config.api_management_api.lz_key, var.client_config.landingzone_key)][try(var.settings.site_config.api_management_api.key, var.settings.site_config.api_management_api_key)].id,
      null
    )
    app_command_line                       = try(var.settings.site_config.app_command_line, null)
    app_scale_limit                        = try(var.settings.site_config.app_scale_limit, null)
    application_insights_connection_string = try(var.settings.site_config.application_insights_connection_string, null)
    application_insights_key               = try(var.settings.site_config.application_insights_key, null)

    dynamic "application_stack" {
      for_each = try(var.settings.site_config.application_stack, {}) != {} ? [1] : []
      content {
        dotnet_version              = try(var.settings.site_config.application_stack.dotnet_version, "v4.0")
        use_dotnet_isolated_runtime = try(var.settings.site_config.application_stack.use_dotnet_isolated_runtime, false)
        java_version                = try(var.settings.site_config.application_stack.java_version, null)
        node_version                = try(var.settings.site_config.application_stack.node_version, null)
        powershell_core_version     = try(var.settings.site_config.application_stack.powershell_core_version, null)
        use_custom_runtime          = try(var.settings.site_config.application_stack.use_custom_runtime, null)
      }
    }

    dynamic "app_service_logs" {
      for_each = try(var.settings.site_config.app_service_logs, {}) != {} ? [1] : []
      content {
        disk_quota_mb         = try(var.settings.site_config.app_service_logs.disk_quota_mb, 35)
        retention_period_days = try(var.settings.site_config.app_service_logs.retention_period_days, null)
      }
    }

    dynamic "cors" {
      for_each = try(var.settings.site_config.cors, {}) != {} ? [1] : []
      content {
        allowed_origins     = try(var.settings.site_config.cors.allowed_origins, null)
        support_credentials = try(var.settings.site_config.cors.support_credentials, false)
      }
    }

    default_documents                 = try(var.settings.site_config.default_documents, null)
    elastic_instance_minimum          = try(var.settings.site_config.elastic_instance_minimum, null)
    ftps_state                        = try(var.settings.site_config.ftps_state, "Disabled")
    health_check_path                 = try(var.settings.site_config.health_check_path, null)
    health_check_eviction_time_in_min = try(var.settings.site_config.health_check_eviction_time_in_min, null)
    http2_enabled                     = try(var.settings.site_config.http2_enabled, false)

    dynamic "ip_restriction" {
      for_each = try(var.settings.site_config.ip_restriction, [])
      content {
        action                    = try(ip_restriction.value.action, "Allow")
        ip_address                = try(ip_restriction.value.ip_address, null)
        name                      = try(ip_restriction.value.name, null)
        priority                  = try(ip_restriction.value.priority, 65000)
        service_tag               = try(ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
        description               = try(ip_restriction.value.description, null)

        dynamic "headers" {
          for_each = try(ip_restriction.value.headers, {}) != {} ? [1] : []
          content {
            x_azure_fdid      = try(ip_restriction.value.headers.x_azure_fdid, null)
            x_fd_health_probe = try(ip_restriction.value.headers.x_fd_health_probe, null)
            x_forwarded_for   = try(ip_restriction.value.headers.x_forwarded_for, null)
            x_forwarded_host  = try(ip_restriction.value.headers.x_forwarded_host, null)
          }
        }
      }
    }

    ip_restriction_default_action    = try(var.settings.site_config.ip_restriction_default_action, "Allow")
    load_balancing_mode              = try(var.settings.site_config.load_balancing_mode, "LeastRequests")
    managed_pipeline_mode            = try(var.settings.site_config.managed_pipeline_mode, "Integrated")
    minimum_tls_version              = try(var.settings.site_config.minimum_tls_version, "1.2")
    pre_warmed_instance_count        = try(var.settings.site_config.pre_warmed_instance_count, null)
    remote_debugging_enabled         = try(var.settings.site_config.remote_debugging_enabled, false)
    remote_debugging_version         = try(var.settings.site_config.remote_debugging_version, null)
    runtime_scale_monitoring_enabled = try(var.settings.site_config.runtime_scale_monitoring_enabled, null)

    dynamic "scm_ip_restriction" {
      for_each = try(var.settings.site_config.scm_ip_restriction, [])
      content {
        action                    = try(scm_ip_restriction.value.action, "Allow")
        ip_address                = try(scm_ip_restriction.value.ip_address, null)
        name                      = try(scm_ip_restriction.value.name, null)
        priority                  = try(scm_ip_restriction.value.priority, 65000)
        service_tag               = try(scm_ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(scm_ip_restriction.value.virtual_network_subnet_id, null)
        description               = try(scm_ip_restriction.value.description, null)

        dynamic "headers" {
          for_each = try(scm_ip_restriction.value.headers, {}) != {} ? [1] : []
          content {
            x_azure_fdid      = try(scm_ip_restriction.value.headers.x_azure_fdid, null)
            x_fd_health_probe = try(scm_ip_restriction.value.headers.x_fd_health_probe, null)
            x_forwarded_for   = try(scm_ip_restriction.value.headers.x_forwarded_for, null)
            x_forwarded_host  = try(scm_ip_restriction.value.headers.x_forwarded_host, null)
          }
        }
      }
    }

    scm_ip_restriction_default_action = try(var.settings.site_config.scm_ip_restriction_default_action, "Allow")
    scm_minimum_tls_version           = try(var.settings.site_config.scm_minimum_tls_version, "1.2")
    scm_use_main_ip_restriction       = try(var.settings.site_config.scm_use_main_ip_restriction, null)
    use_32_bit_worker                 = try(var.settings.site_config.use_32_bit_worker, true)
    vnet_route_all_enabled            = try(var.settings.site_config.vnet_route_all_enabled, false)
    websockets_enabled                = try(var.settings.site_config.websockets_enabled, false)
    worker_count                      = try(var.settings.site_config.worker_count, null)
  }

  dynamic "connection_string" {
    for_each = try(var.settings.connection_string, [])
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = var.settings.identity.type
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
    }
  }

  dynamic "storage_account" {
    for_each = try(var.settings.storage_account, [])
    content {
      access_key = coalesce(
        try(storage_account.value.access_key, null),
        try(var.remote_objects.storage_accounts[try(storage_account.value.lz_key, var.client_config.landingzone_key)][try(storage_account.value.key, storage_account.value.storage_account_key)].primary_access_key, null),
        var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][try(var.settings.storage_account.key, var.settings.storage_account_key)].primary_access_key
      )
      account_name = storage_account.value.account_name
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = try(storage_account.value.mount_path, null)
    }
  }

  storage_account_access_key = try(
    var.settings.storage_account_access_key,
    var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][try(var.settings.storage_account.key, var.settings.storage_account_key)].primary_access_key,
    null
  )

  storage_account_name = try(
    var.settings.storage_account_name,
    var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][try(var.settings.storage_account.key, var.settings.storage_account_key)].name,
    null
  )

  storage_uses_managed_identity = try(var.settings.storage_uses_managed_identity, null)
  storage_key_vault_secret_id   = try(var.settings.storage_key_vault_secret_id, null)

  tags = local.tags

  virtual_network_backup_restore_enabled = try(var.settings.virtual_network_backup_restore_enabled, false)
  virtual_network_subnet_id = try(
    var.settings.virtual_network_subnet_id,
    var.remote_objects.vnets[try(var.settings.virtual_network_subnet.lz_key, var.client_config.landingzone_key)][var.settings.virtual_network_subnet.vnet_key].subnets[var.settings.virtual_network_subnet.subnet_key].id,
    null
  )

  vnet_image_pull_enabled                        = try(var.settings.vnet_image_pull_enabled, false)
  webdeploy_publish_basic_authentication_enabled = try(var.settings.webdeploy_publish_basic_authentication_enabled, true)
  zip_deploy_file                                = try(var.settings.zip_deploy_file, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(var.settings.timeouts.create, null)
      update = try(var.settings.timeouts.update, null)
      read   = try(var.settings.timeouts.read, null)
      delete = try(var.settings.timeouts.delete, null)
    }
  }
}

module "slots" {
  source   = "./windows_function_app_slot"
  for_each = try(var.settings.slots, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    function_app_id = azurerm_windows_function_app.windows_function_app.id
  })

  depends_on = [azurerm_windows_function_app.windows_function_app]
}
