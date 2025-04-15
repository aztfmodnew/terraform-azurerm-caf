resource "azurerm_windows_web_app_slot" "windows_web_app_slot" {
  name           = var.settings.name
  app_service_id = var.remote_objects.app_service_id
  service_plan_id = coalesce(
    try(var.settings.service_plan_id, null),
    try(var.remote_objects.service_plans[try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null),
    try(var.remote_objects.app_service_plans[try(var.settings.app_service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_plan.key, var.settings.app_service_plan_key)].id, null)
  )
  site_config {
    always_on                                     = try(var.settings.site_config.always_on, true)
    api_definition_url                            = try(var.settings.site_config.api_definition_url, null)
    api_management_api_id                         = try(var.settings.site_config.api_management_api_id, null)
    app_command_line                              = try(var.settings.site_config.app_command_line, null)
    container_registry_managed_identity_client_id = try(var.settings.site_config.container_registry_managed_identity_client_id, null)
    container_registry_use_managed_identity       = try(var.settings.site_config.container_registry_use_managed_identity, null)
    default_documents                             = try(var.settings.site_config.default_documents, null)
    ftps_state                                    = try(var.settings.site_config.ftps_state, "Disabled")
    health_check_path                             = try(var.settings.site_config.health_check_path, null)
    health_check_eviction_time_in_min             = try(var.settings.site_config.health_check_eviction_time_in_min, null)
    http2_enabled                                 = try(var.settings.site_config.http2_enabled, null)
    ip_restriction_default_action                 = try(var.settings.site_config.ip_restriction_default_action, "Allow")
    load_balancing_mode                           = try(var.settings.site_config.load_balancing_mode, "LeastRequests")
    local_mysql_enabled                           = try(var.settings.site_config.local_mysql_enabled, null)
    managed_pipeline_mode                         = try(var.settings.site_config.managed_pipeline_mode, "Integrated")
    minimum_tls_version                           = try(var.settings.site_config.minimum_tls_version, "1.2")
    remote_debugging_enabled                      = try(var.settings.site_config.remote_debugging_enabled, false)
    remote_debugging_version                      = try(var.settings.site_config.remote_debugging_version, null)
    scm_ip_restriction_default_action             = try(var.settings.site_config.scm_ip_restriction_default_action, "Allow")
    scm_minimum_tls_version                       = try(var.settings.site_config.scm_minimum_tls_version, "1.2")
    scm_use_main_ip_restriction                   = try(var.settings.site_config.scm_use_main_ip_restriction, null)
    use_32_bit_worker                             = try(var.settings.site_config.use_32_bit_worker, true)
    vnet_route_all_enabled                        = try(var.settings.site_config.vnet_route_all_enabled, false)
    websockets_enabled                            = try(var.settings.site_config.websockets_enabled, false)
    worker_count                                  = try(var.settings.site_config.worker_count, null)

    dynamic "application_stack" {
      for_each = try(var.settings.site_config.application_stack, null) == null ? [] : [var.settings.site_config.application_stack]
      content {
        current_stack                = try(application_stack.value.current_stack, null)
        docker_image_name            = try(application_stack.value.docker_image_name, null)
        docker_registry_url          = try(application_stack.value.docker_registry_url, null)
        docker_registry_username     = try(application_stack.value.docker_registry_username, null)
        docker_registry_password     = try(application_stack.value.docker_registry_password, null)
        dotnet_version               = try(application_stack.value.dotnet_version, null)
        dotnet_core_version          = try(application_stack.value.dotnet_core_version, null)
        tomcat_version               = try(application_stack.value.tomcat_version, null)
        java_embedded_server_enabled = try(application_stack.value.java_embedded_server_enabled, null)
        java_version                 = try(application_stack.value.java_version, null)
        node_version                 = try(application_stack.value.node_version, null)
        php_version                  = try(application_stack.value.php_version, null)
        python                       = try(application_stack.value.python, null)
      }
    }

    dynamic "auto_heal_setting" {
      for_each = try(var.settings.site_config.auto_heal_setting, null) == null ? [] : [var.settings.site_config.auto_heal_setting]
      content {
        action {
          action_type                    = auto_heal_setting.value.action.action_type
          minimum_process_execution_time = try(auto_heal_setting.value.action.minimum_process_execution_time, null)

          dynamic "custom_action" {
            for_each = try(auto_heal_setting.value.action.custom_action, null) == null ? [] : [auto_heal_setting.value.action.custom_action]
            content {
              executable = custom_action.value.executable
              parameters = try(custom_action.value.parameters, null)
            }
          }
        }

        trigger {
          private_memory_kb = try(auto_heal_setting.value.trigger.private_memory_kb, null)

          dynamic "requests" {
            for_each = try(auto_heal_setting.value.trigger.requests, null) == null ? [] : [auto_heal_setting.value.trigger.requests]
            content {
              count    = requests.value.count
              interval = requests.value.interval
            }
          }

          dynamic "slow_request" {
            for_each = try(auto_heal_setting.value.trigger.slow_request, null) == null ? [] : [auto_heal_setting.value.trigger.slow_request]
            content {
              count      = slow_request.value.count
              interval   = slow_request.value.interval
              time_taken = slow_request.value.time_taken
            }
          }

          dynamic "slow_request_with_path" {
            for_each = try(auto_heal_setting.value.trigger.slow_request_with_path, [])
            content {
              count      = slow_request_with_path.value.count
              interval   = slow_request_with_path.value.interval
              time_taken = slow_request_with_path.value.time_taken
              path       = try(slow_request_with_path.value.path, null)
            }
          }

          dynamic "status_code" {
            for_each = try(auto_heal_setting.value.trigger.status_code, [])
            content {
              count             = status_code.value.count
              interval          = status_code.value.interval
              status_code_range = status_code.value.status_code_range
              path              = try(status_code.value.path, null)
              sub_status        = try(status_code.value.sub_status, null)
              win32_status_code = try(status_code.value.win32_status_code, null)
            }
          }
        }
      }
    }
  }
  app_settings = try(local.app_settings, null)


  dynamic "auth_settings" {
    for_each = try(var.settings.auth_settings, {}) != {} ? var.settings.auth_settings : []
    content {
      enabled = try(var.settings.auth_settings.enabled, null)
      dynamic "active_directory" {
        for_each = try(var.settings.auth_settings.active_directory, {}) != {} ? var.settings.auth_settings.active_directory : []
        content {
          client_id         = var.settings.auth_settings.active_directory.client_id
          client_secret     = try(var.settings.auth_settings.active_directory.client_secret, null)
          allowed_audiences = try(var.settings.auth_settings.active_directory.allowed_audiences, null)
        }
      }
      additional_login_parameters    = try(var.settings.auth_settings.additional_login_parameters, null)
      allowed_external_redirect_urls = try(var.settings.auth_settings.allowed_external_redirect_urls, null)
      default_provider               = try(var.settings.auth_settings.default_provider, null)

      dynamic "facebook" {
        for_each = try(var.settings.auth_settings.facebook, {}) != {} ? var.settings.auth_settings.facebook : []
        content {
          app_id                  = var.settings.auth_settings.facebook.app_id
          app_secret              = try(var.settings.auth_settings.facebook.app_secret, null)
          app_secret_setting_name = try(var.settings.auth_settings.facebook.app_secret_setting_name, null)
          oauth_scopes            = try(var.settings.auth_settings.facebook.oauth_scopes, null)
        }
      }

      dynamic "github" {
        for_each = try(var.settings.auth_settings.github, {}) != {} ? var.settings.auth_settings.github : []
        content {
          client_id                  = var.settings.auth_settings.github.client_id
          client_secret              = try(var.settings.auth_settings.github.client_secret, null)
          client_secret_setting_name = try(var.settings.auth_settings.github.client_secret_setting_name, null)
          oauth_scopes               = try(var.settings.auth_settings.github.oauth_scopes, null)
        }
      }

      dynamic "google" {
        for_each = lookup(var.settings.auth_settings, "google", {}) != {} ? var.settings.auth_settings.google : []

        content {
          client_id                  = var.settings.auth_settings.google.client_id
          client_secret              = try(var.settings.auth_settings.google.client_secret, null)
          client_secret_setting_name = try(var.settings.auth_settings.google.client_secret_setting_name, null)
          oauth_scopes               = try(var.settings.auth_settings.google.oauth_scopes, null)
        }
      }



      dynamic "twitter" {
        for_each = lookup(var.settings.auth_settings, "twitter", {}) != {} ? var.settings.auth_settings.twitter : []

        content {
          consumer_key    = var.settings.auth_settings.twitter.consumer_key
          consumer_secret = var.settings.auth_settings.twitter.consumer_secret
        }
      }

      issuer = try(var.settings.auth_settings.issuer, null)

      dynamic "microsoft" {
        for_each = lookup(var.settings.auth_settings, "microsoft", {}) != {} ? var.settings.auth_settings.microsoft : []

        content {
          client_id                  = var.settings.auth_settings.microsoft.client_id
          client_secret              = try(var.settings.auth_settings.microsoft.client_secret, null)
          client_secret_setting_name = try(var.settings.auth_settings.microsoft.client_secret_setting_name, null)
          oauth_scopes               = lookup(var.settings.auth_settings.microsoft, "oauth_scopes", null)
        }
      }

      runtime_version               = try(var.settings.auth_settings.runtime_version, null)
      token_refresh_extension_hours = try(var.settings.auth_settings.token_refresh_extension_hours, 72)
      token_store_enabled           = try(var.settings.auth_settings.token_store_enabled, null)
      unauthenticated_client_action = try(var.settings.auth_settings.unauthenticated_client_action, null)
    }

  }

  dynamic "auth_settings_v2" {
    for_each = try(var.settings.auth_settings_v2, {}) != {} ? var.settings.auth_settings_v2 : []
    content {
      auth_enabled                            = try(var.settings.auth_settings_v2.auth_enabled, null)
      runtime_version                         = try(var.settings.auth_settings_v2.runtime_version, "~1")
      config_file_path                        = try(var.settings.auth_settings_v2.config_file_path, null)
      require_authentication                  = try(var.settings.auth_settings_v2.require_authentication, null)
      unauthenticated_action                  = try(var.settings.auth_settings_v2.unauthenticated_action, null)
      default_provider                        = try(var.settings.auth_settings_v2.default_provider, null)
      excluded_paths                          = try(var.settings.auth_settings_v2.excluded_paths, null)
      require_https                           = try(var.settings.auth_settings_v2.require_https, null)
      http_route_api_prefix                   = try(var.settings.auth_settings_v2.http_route_api_prefix, "/.auth")
      forward_proxy_convention                = try(var.settings.auth_settings_v2.forward_proxy_convention, "NoProxy")
      forward_proxy_custom_host_header_name   = try(var.settings.auth_settings_v2.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(var.settings.auth_settings_v2.forward_proxy_custom_scheme_header_name, null)

      dynamic "apple_v2" {
        for_each = try(var.settings.auth_settings_v2.apple_v2, {}) != {} ? var.settings.auth_settings_v2.apple_v2 : []
        content {
          client_id                  = var.settings.auth_settings_v2.apple_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.apple_v2.client_secret_setting_name
          login_scopes               = var.settings.auth_settings_v2.apple_v2.login_scopes
        }
      }

      dynamic "active_directory_v2" {
        for_each = try(var.settings.auth_settings_v2.active_directory_v2, {}) != {} ? var.settings.auth_settings_v2.active_directory_v2 : []
        content {
          client_id                            = var.settings.auth_settings_v2.active_directory_v2.client_id
          tenant_auth_endpoint                 = var.settings.auth_settings_v2.active_directory_v2.tenant_auth_endpoint
          client_secret_setting_name           = try(var.settings.auth_settings_v2.active_directory_v2.client_secret_setting_name, null)
          client_secret_certificate_thumbprint = try(var.settings.auth_settings_v2.active_directory_v2.client_secret_certificate_thumbprint, null)
          jwt_allowed_groups                   = try(var.settings.auth_settings_v2.active_directory_v2.jwt_allowed_groups, null)
          jwt_allowed_client_applications      = try(var.settings.auth_settings_v2.active_directory_v2.jwt_allowed_client_applications, null)
          www_authentication_disabled          = try(var.settings.auth_settings_v2.active_directory_v2.www_authentication, null)
          allowed_groups                       = try(var.settings.auth_settings_v2.active_directory_v2.allowed_groups, null)
          allowed_identities                   = try(var.settings.auth_settings_v2.active_directory_v2.allowed_identities, null)
          allowed_applications                 = try(var.settings.auth_settings_v2.active_directory_v2.allowed_applications, null)
          login_parameters                     = try(var.settings.auth_settings_v2.active_directory_v2.login_parameters, null)
          allowed_audiences                    = try(var.settings.auth_settings_v2.active_directory_v2.allowed_audiences, null)
        }
      }

      dynamic "azure_static_web_app_v2" {
        for_each = try(var.settings.auth_settings_v2.azure_static_web_app_v2, {}) != {} ? var.settings.auth_settings_v2.azure_static_web_app_v2 : []
        content {
          client_id = var.settings.auth_settings_v2.azure_static_web_app_v2.client_id
        }
      }
      #(Optional) Zero or more custom_oidc_v2 blocks as defined below.
      dynamic "custom_oidc_v2" {
        for_each = try(var.settings.auth_settings_v2.custom_oidc_v2, [])
        content {
          name                          = var.settings.auth_settings_v2.custom_oidc_v2.name
          client_id                     = var.settings.auth_settings_v2.custom_oidc_v2.client_id
          openid_configuration_endpoint = var.settings.auth_settings_v2.custom_oidc_v2.openid_configuration_endpoint
          name_claim_type               = try(var.settings.auth_settings_v2.custom_oidc_v2.name_claim_type, null)
          scopes                        = try(var.settings.auth_settings_v2.custom_oidc_v2.scopes, null)
          client_credential_method      = try(var.settings.auth_settings_v2.custom_oidc_v2.client_credential_method, null)
          client_secret_setting_name    = try(var.settings.auth_settings_v2.custom_oidc_v2.client_secret_setting_name, null)
          authorisation_endpoint        = try(var.settings.auth_settings_v2.custom_oidc_v2.authorisation_endpoint, null)
          token_endpoint                = try(var.settings.auth_settings_v2.custom_oidc_v2.token_endpoint, null)
          issuer_endpoint               = try(var.settings.auth_settings_v2.custom_oidc_v2.issuer_endpoint, null)
          certification_uri             = try(var.settings.auth_settings_v2.custom_oidc_v2.certification_uri, null)
        }
      }

      dynamic "facebook_v2" {
        for_each = try(var.settings.auth_settings_v2.facebook_v2, {}) != {} ? var.settings.auth_settings_v2.facebook_v2 : []
        content {
          app_id                  = var.settings.auth_settings_v2.facebook_v2.app_id
          app_secret_setting_name = var.settings.auth_settings_v2.facebook_v2.app_secret_setting_name
          graph_api_version       = try(var.settings.auth_settings_v2.facebook_v2.graph_api_version, null)
          login_scopes            = try(var.settings.auth_settings_v2.facebook_v2.login_scopes, null)
        }
      }

      dynamic "github_v2" {
        for_each = try(var.settings.auth_settings_v2.github_v2, {}) != {} ? var.settings.auth_settings_v2.github_v2 : []
        content {
          client_id                  = var.settings.auth_settings_v2.github_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.github_v2.client_secret_setting_name
          login_scopes               = try(var.settings.auth_settings_v2.github_v2.login_scopes, null)
        }
      }

      dynamic "google_v2" {
        for_each = try(var.settings.auth_settings_v2.google_v2, {}) != {} ? var.settings.auth_settings_v2.google_v2 : []
        content {
          client_id                  = var.settings.auth_settings_v2.google_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.google_v2.client_secret_setting_name
          allowed_audiences          = try(var.settings.auth_settings_v2.google_v2.allowed_audiences, null)
          login_scopes               = try(var.settings.auth_settings_v2.google_v2.login_scopes, null)
        }
      }

      dynamic "microsoft_v2" {
        for_each = try(var.settings.auth_settings_v2.microsoft_v2, {}) != {} ? var.settings.auth_settings_v2.microsoft_v2 : []
        content {
          client_id                  = var.settings.auth_settings_v2.microsoft_v2.client_id
          client_secret_setting_name = var.settings.auth_settings.microsoft_v2.client_secret_setting_name
          allowed_audiences          = try(var.settings.auth_settings.microsoft_v2.allowed_audiences, null)
          login_scopes               = try(var.settings.auth_settings.microsoft_v2.login_scopes, null)
        }
      }

      dynamic "twitter_v2" {
        for_each = try(var.settings.auth_settings_v2.twitter_v2, {}) != {} ? var.settings.auth_settings_v2.twitter_v2 : []
        content {
          consumer_key                 = var.settings.auth_settings_v2.twitter_v2.consumer_key
          consumer_secret_setting_name = var.settings.auth_settings_v2.twitter_v2.consumer_secret_setting_name
        }
      }

      dynamic "login" {
        for_each = try(var.settings.auth_settings_v2.login, {}) != {} ? var.settings.auth_settings_v2.login : []
        content {
          logout_endpoint                   = try(var.settings.auth_settings_v2.login.logout_endpoint, null)
          token_store_enabled               = try(var.settings.auth_settings_v2.login.token_store_enabled, null)
          token_refresh_extension_time      = try(var.settings.auth_settings_v2.login.token_refresh_extension_time, null)
          token_store_path                  = try(var.settings.auth_settings_v2.login.token_store_path, null)
          token_store_sas_setting_name      = try(var.settings.auth_settings_v2.login.token_store_sas_setting_name, null)
          preserve_url_fragments_for_logins = try(var.settings.auth_settings_v2.login.preserve_url_fragments_for_logins, null)
          allowed_external_redirect_urls    = try(var.settings.auth_settings_v2.login.allowed_external_redirect_urls, null)
          cookie_expiration_convention      = try(var.settings.auth_settings_v2.login.cookie_expiration_convention, null)
          cookie_expiration_time            = try(var.settings.auth_settings_v2.login.cookie_expiration_time, null)
          validate_nonce                    = try(var.settings.auth_settings_v2.login.validate_nonce, null)
          nonce_expiration_time             = try(var.settings.auth_settings_v2.login.nonce_expiration_time, null)
        }
      }

    }

  }

  dynamic "backup" {
    for_each = try(var.settings.backup, {}) != {} ? var.settings.backup : []
    content {
      name = var.settings.backup.name
      schedule {
        frequency_interval       = var.settings.backup.schedule.frequency_interval
        frequency_unit           = var.settings.backup.schedule.frequency_unit
        keep_at_least_one_backup = try(var.settings.backup.schedule.keep_at_least_one_backup, null)
        retention_period_days    = try(var.settings.backup.schedule.retention_period_days, null)
        start_time               = try(var.settings.backup.schedule.start_time, null)
      }
      storage_account_url = try(
        var.settings.backup.storage_account_url,
        var.remote_objects.storage_accounts[try(var.settings.backup.storage_account.lz_key, var.client_config.landingzone_key)][try(var.settings.backup.storage_account.key, var.settings.backup.storage_account_key)].primary_blob_connection_string,
        local.backup_sas_url
      )
      enabled = try(var.settings.backup.enabled, null)
    }
  }

  client_affinity_enabled            = try(var.settings.client_affinity_enabled, null)
  client_certificate_enabled         = try(var.settings.client_certificate_enabled, null)
  client_certificate_mode            = try(var.settings.client_certificate_mode, null)
  client_certificate_exclusion_paths = try(var.settings.client_certificate_exclusion_paths, null)
  dynamic "connection_string" {
    for_each = try(var.settings.connection_string, {}) != {} ? var.settings.connection_string : []
    content {
      name  = var.settings.connection_string.name
      type  = var.settings.connection_string.type
      value = var.settings.connection_string.value
    }
  }
  enabled                                  = try(var.settings.enabled, true)
  ftp_publish_basic_authentication_enabled = try(var.settings.ftp_publish_basic_authentication_enabled, true)
  https_only                               = try(var.settings.https_only, false)
  public_network_access_enabled            = try(var.settings.public_network_access_enabled, true)
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = var.settings.identity.type
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
    }
  }

  key_vault_reference_identity_id = try(
    var.settings.key_vault_reference_identity_id,
    var.remote_objects.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][try(var.settings.key_vault_reference_identity.key, var.settings.key_vault_reference_identity_key)].id,
    null
  )

  dynamic "logs" {
    for_each = try(var.settings.logs, {}) != {} ? var.settings.logs : []
    content {
      dynamic "application_logs" {
        for_each = try(var.settings.logs.application_logs, {}) != {} ? var.settings.logs.application_logs : []
        content {
          dynamic "azure_blob_storage" {
            for_each = try(var.settings.logs.application_logs.azure_blob_storage, {}) != {} ? var.settings.logs.application_logs.azure_blob_storage : []
            content {
              level             = try(var.settings.logs.application_logs.azure_blob_storage.level, "Error")
              retention_in_days = try(var.settings.logs.application_logs.azure_blob_storage.retention_in_days, 7)
              sas_url           = try(var.settings.logs.application_logs.azure_blob_storage.sas_url, local.logs_sas_url)
            }
          }
          file_system_level = try(var.settings.logs.application_logs.file_system_level, "Error")

        }
      }
      detailed_error_messages = try(var.settings.logs.detailed_error_messages, true)
      failed_request_tracing  = try(var.settings.logs.failed_request_tracing, true)
      dynamic "http_logs" {
        for_each = try(var.settings.logs.http_logs, {}) != {} ? var.settings.logs.http_logs : []
        content {
          dynamic "azure_blob_storage" {
            for_each = try(http_logs.value.azure_blob_storage, {}) != {} ? http_logs.value.azure_blob_storage : []
            content {
              retention_in_days = try(http_logs.value.azure_blob_storage.retention_in_days, 7)
              sas_url           = try(http_logs.value.azure_blob_storage.sas_url, local.http_logs_sas_url)
            }
          }
          dynamic "file_system" {
            for_each = try(http_logs.value.file_system, {}) != {} ? http_logs.value.file_system : []
            content {
              retention_in_days = try(http_logs.value.file_system.retention_in_days, 7)
              retention_in_mb   = try(http_logs.value.file_system.retention_in_mb, 35)
            }
          }
        }
      }
    }
  }



  dynamic "storage_account" {
    for_each = try(var.settings.storage_account, {}) != {} ? var.settings.storage_account : []
    content {
      access_key = try(
        var.settings.storage_account.access_key,
        var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][try(var.settings.storage_account.key, var.settings.storage_account_key)].primary_access_key
      )
      account_name = var.settings.storage_account.account_name
      name         = var.settings.storage_account.name
      share_name   = var.settings.storage_account.share_name
      type         = var.settings.storage_account.type
      mount_path   = try(var.settings.storage_account.mount_path, null)
    }
  }





  tags = local.tags

  virtual_network_subnet_id = try(
    var.settings.virtual_network_subnet_id,
    var.remote_objects.vnets[try(var.settings.virtual_network_subnet.lz_key, var.client_config.landingzone_key)][var.settings.virtual_network_subnet.vnet_key].subnets[var.settings.virtual_network_subnet.subnet_key].id,
    null
  )

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