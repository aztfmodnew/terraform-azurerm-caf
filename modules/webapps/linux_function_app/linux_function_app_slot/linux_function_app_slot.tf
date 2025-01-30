# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app
# versión 4.16.0



resource "azurerm_linux_function_app_slot" "linux_function_app_slot" {
  name            = azurecaf_name.linux_function_app_slot.result
  function_app_id = var.remote_objects.function_app_id
  site_config {
    always_on          = try(var.settings.site_config.always_on, null)
    api_definition_url = try(var.settings.site_config.api_definition_url, null)
    api_management_api_id = coalesce(
      try(var.settings.site_config.api_management_api_id, null),
      try(var.remote_objects.api_management_apis[try(var.settings.site_config.api_management_api.lz_key, var.client_config.landingzone_key)][var.settings.site_config.api_management_api.key].id, null)
    )
    app_command_line                       = try(var.settings.site_config.app_command_line, null)
    app_scale_limit                        = try(var.settings.site_config.app_scale_limit, null)
    application_insights_connection_string = try(var.settings.site_config.application_insights_connection_string, null)
    application_insights_key               = try(var.settings.site_config.application_insigths_key, null)
    dynamic "application_stack" {
      for_each = try(var.settings.site_config.application_stack, {}) != {} ? [1] : []
      content {
        dynamic "docker" {
          for_each = try(var.settings.site_config.application_stack.docker, [])
          content {
            registry_url      = var.settings.site_config.application_stack.docker.registry_url
            image_name        = var.settings.site_config.application_stack.docker.image_name
            image_tag         = var.settings.site_config.application_stack.docker.image_tag
            registry_username = try(var.settings.site_config.application_stack.docker.registry_username, null)
            registry_password = try(var.settings.site_config.application_stack.docker.registry_password, null)
          }
        }
        dotnet_version              = try(var.settings.site_config.application_stack.dotnet_version, null)
        use_dotnet_isolated_runtime = try(var.settings.site_config.application_stack.use_dotnet_isolated_runtime, null)
        java_version                = try(var.settings.site_config.application_stack.java_version, null)
        node_version                = try(var.settings.site_config.application_stack.node_version, null)
        python_version              = try(var.settings.site_config.application_stack.python_version, null)
        powershell_core_version     = try(var.settings.site_config.application_stack.powershell_core_version, null)
        use_custom_runtime          = try(var.settings.site_config.application_stack.use_custom_runtime, null)
      }

    }
    dynamic "app_service_logs" {
      for_each = try(var.settings.site_config.app_service_logs, {}) != {} ? [1] : []
      content {
        disk_quota_mb         = try(var.settings.site_config.app_service_logs.disk_quota_mb, null)
        retention_period_days = try(var.settings.site_config.app_service_logs.retention_period_days, null)
      }
    }

    container_registry_managed_identity_client_id = try(var.settings.site_config.container_registry_managed_identity_client_id, null)
    container_registry_use_managed_identity       = try(var.settings.site_config.container_registry_use_managed_identity, null)
    dynamic "cors" {
      for_each = try(var.settings.site_config.cors, {}) != {} ? [1] : []
      content {
        allowed_origins     = try(var.settings.site_config.cors.allowed_origins, null)
        support_credentials = try(var.settings.site_config.cors.support_credentials, null)
      }
    }
    default_documents                 = try(var.settings.site_config.default_documents, null)
    elastic_instance_minimum          = try(var.settings.site_config.elastic_instance_minimum, null)
    ftps_state                        = try(var.settings.site_config.ftps_state, null)
    health_check_path                 = try(var.settings.site_config.health_check_path, null)
    health_check_eviction_time_in_min = try(var.settings.site_config.health_check_eviction_time_in_min, null)
    dynamic "ip_restriction" {
      for_each = try(var.settings.site_config.ip_restriction, [])
      content {
        action                    = try(var.settings.site_config.ip_restriction.action, null)
        ip_address                = try(var.settings.site_config.ip_restriction.ip_address, null)
        name                      = try(var.settings.site_config.ip_restriction.name, null)
        priority                  = try(var.settings.site_config.ip_restriction.priority, null)
        service_tag               = try(var.settings.site_config.ip_restriction.service_tag, null)
        virtual_network_subnet_id = try(var.settings.site_config.ip_restriction.virtual_network_subnet_id, null)
        description               = try(var.settings.site_config.ip_restriction.description, null)
      }

    }
    ip_restriction_default_action    = try(var.settings.site_config.ip_restriction_default_action, null)
    load_balancing_mode              = try(var.settings.site_config.load_balancing_mode, null)
    managed_pipeline_mode            = try(var.settings.site_config.managed_pipeline_mode, null)
    minimum_tls_version              = try(var.settings.site_config.minimum_tls_version, null)
    pre_warmed_instance_count        = try(var.settings.site_config.pre_warmed_instance_count, null)
    remote_debugging_enabled         = try(var.settings.site_config.remote_debugging_enabled, false)
    remote_debugging_version         = try(var.settings.site_config.remote_debugging_version, null)
    runtime_scale_monitoring_enabled = try(var.settings.site_config.runtime_scale_monitoring_enabled, null)
    dynamic "scm_ip_restriction" {
      for_each = try(var.settings.site_config.scm_ip_restriction, [])
      content {
        action                    = try(var.settings.site_config.scm_ip_restriction.action, null)
        ip_address                = try(var.settings.site_config.scm_ip_restriction.ip_address, null)
        name                      = try(var.settings.site_config.scm_ip_restriction.name, null)
        priority                  = try(var.settings.site_config.scm_ip_restriction.priority, null)
        service_tag               = try(var.settings.site_config.scm_ip_restriction.service_tag, null)
        virtual_network_subnet_id = try(var.settings.site_config.scm_ip_restriction.virtual_network_subnet_id, null)
        description               = try(var.settings.site_config.scm_ip_restriction.description, null)
      }
    }
    scm_ip_restriction_default_action = try(var.settings.site_config.scm_ip_restriction_default_action, null)
    scm_minimum_tls_version           = try(var.settings.site_config.scm_minimum_tls_version, 1.2)
    scm_use_main_ip_restriction       = try(var.settings.site_config.scm_use_main_ip_restriction, null)
    use_32_bit_worker                 = try(var.settings.site_config.use_32_bit_worker, false)
    vnet_route_all_enabled            = try(var.settings.site_config.vnet_route_all_enabled, false)
    websockets_enabled                = try(var.settings.site_config.websockets_enabled, false)
    worker_count                      = try(var.settings.site_config.worker_count, null)
  }
  app_settings = local.app_settings

  dynamic "auth_settings" {
    for_each = try(var.settings.auth_settings, {}) != {} ? [1] : []
    content {
      enabled = try(var.settings.auth_settings.enabled, null)
      dynamic "active_directory" {
        for_each = try(var.settings.auth_settings.active_directory, {}) != {} ? [1] : []
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
        for_each = try(var.settings.auth_settings.facebook, {}) != {} ? [1] : []
        content {
          app_id                  = var.settings.auth_settings.facebook.app_id
          app_secret              = try(var.settings.auth_settings.facebook.app_secret, null)
          app_secret_setting_name = try(var.settings.auth_settings.facebook.app_secret_setting_name, null)
          oauth_scopes            = try(var.settings.auth_settings.facebook.oauth_scopes, null)
        }
      }

      dynamic "github" {
        for_each = try(var.settings.auth_settings.github, {}) != {} ? [1] : []
        content {
          client_id                  = var.settings.auth_settings.github.client_id
          client_secret              = try(var.settings.auth_settings.github.client_secret, null)
          client_secret_setting_name = try(var.settings.auth_settings.github.client_secret_setting_name, null)
          oauth_scopes               = try(var.settings.auth_settings.github.oauth_scopes, null)
        }
      }

      dynamic "google" {
        for_each = lookup(var.settings.auth_settings, "google", {}) != {} ? [1] : []

        content {
          client_id                  = var.settings.auth_settings.google.client_id
          client_secret              = try(var.settings.auth_settings.google.client_secret, null)
          client_secret_setting_name = try(var.settings.auth_settings.google.client_secret_setting_name, null)
          oauth_scopes               = try(var.settings.auth_settings.google.oauth_scopes, null)
        }
      }



      dynamic "twitter" {
        for_each = lookup(var.settings.auth_settings, "twitter", {}) != {} ? [1] : []

        content {
          consumer_key    = var.settings.auth_settings.twitter.consumer_key
          consumer_secret = var.settings.auth_settings.twitter.consumer_secret
        }
      }

      issuer = try(var.settings.auth_settings.issuer, null)

      dynamic "microsoft" {
        for_each = lookup(var.settings.auth_settings, "microsoft", {}) != {} ? [1] : []

        content {
          client_id                  = var.settings.auth_settings.microsoft.client_id
          client_secret              = try(var.settings.auth_settings.microsoft.client_secret, null)
          client_secret_setting_name = try(var.settings.auth_settings.microsoft.client_secret_setting_name, null)
          oauth_scopes               = lookup(var.settings.auth_settings.microsoft, "oauth_scopes", null)
        }
      }

      runtime_version               = try(var.settings.auth_settings.runtime_version, null)
      token_refresh_extension_hours = try(var.settings.auth_settings.token_refresh_extension_hours, 72)
      token_store_enabled           = try(var.settings.auth_settings.token_store_enabled, false)
      unauthenticated_client_action = try(var.settings.auth_settings.unauthenticated_client_action, null)
    }

  }

  dynamic "auth_settings_v2" {
    for_each = try(var.settings.auth_settings_v2, {}) != {} ? [1] : []
    content {
      auth_enabled                            = try(var.settings.auth_settings_v2.auth_enabled, false)
      runtime_version                         = try(var.settings.auth_settings_v2.runtime_version, "~1")
      config_file_path                        = try(var.settings.auth_settings_v2.config_file_path, null)
      require_authentication                  = try(var.settings.auth_settings_v2.require_authentication, null)
      unauthenticated_action                  = try(var.settings.auth_settings_v2.unauthenticated_action, null)
      default_provider                        = try(var.settings.auth_settings_v2.default_provider, null)
      excluded_paths                          = try(var.settings.auth_settings_v2.excluded_paths, null)
      require_https                           = try(var.settings.auth_settings_v2.require_https, true)
      http_route_api_prefix                   = try(var.settings.auth_settings_v2.http_route_api_prefix, "/.auth")
      forward_proxy_convention                = try(var.settings.auth_settings_v2.forward_proxy_convention, "NoProxy")
      forward_proxy_custom_host_header_name   = try(var.settings.auth_settings_v2.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(var.settings.auth_settings_v2.forward_proxy_custom_scheme_header_name, null)

      dynamic "apple_v2" {
        for_each = try(var.settings.auth_settings_v2.apple_v2, {}) != {} ? [1] : []
        content {
          client_id                  = var.settings.auth_settings_v2.apple_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.apple_v2.client_secret_setting_name
          login_scopes               = var.settings.auth_settings_v2.apple_v2.login_scopes
        }
      }

      dynamic "active_directory_v2" {
        for_each = try(var.settings.auth_settings_v2.active_directory_v2, {}) != {} ? [1] : []
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
        for_each = try(var.settings.auth_settings_v2.azure_static_web_app_v2, {}) != {} ? [1] : []
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
        for_each = try(var.settings.auth_settings_v2.facebook_v2, {}) != {} ? [1] : []
        content {
          app_id                  = var.settings.auth_settings_v2.facebook_v2.app_id
          app_secret_setting_name = var.settings.auth_settings_v2.facebook_v2.app_secret_setting_name
          graph_api_version       = try(var.settings.auth_settings_v2.facebook_v2.graph_api_version, null)
          login_scopes            = try(var.settings.auth_settings_v2.facebook_v2.login_scopes, null)
        }
      }

      dynamic "github_v2" {
        for_each = try(var.settings.auth_settings_v2.github_v2, {}) != {} ? [1] : []
        content {
          client_id                  = var.settings.auth_settings_v2.github_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.github_v2.client_secret_setting_name
          login_scopes               = try(var.settings.auth_settings_v2.github_v2.login_scopes, null)
        }
      }

      dynamic "google_v2" {
        for_each = try(var.settings.auth_settings_v2.google_v2, {}) != {} ? [1] : []
        content {
          client_id                  = var.settings.auth_settings_v2.google_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.google_v2.client_secret_setting_name
          allowed_audiences          = try(var.settings.auth_settings_v2.google_v2.allowed_audiences, null)
          login_scopes               = try(var.settings.auth_settings_v2.google_v2.login_scopes, null)
        }
      }

      dynamic "microsoft_v2" {
        for_each = try(var.settings.auth_settings_v2.microsoft_v2, {}) != {} ? [1] : []
        content {
          client_id                  = var.settings.auth_settings_v2.microsoft_v2.client_id
          client_secret_setting_name = var.settings.auth_settings.microsoft_v2.client_secret_setting_name
          allowed_audiences          = try(var.settings.auth_settings.microsoft_v2.allowed_audiences, null)
          login_scopes               = try(var.settings.auth_settings.microsoft_v2.login_scopes, null)
        }
      }

      dynamic "twitter_v2" {
        for_each = try(var.settings.auth_settings_v2.twitter_v2, {}) != {} ? [1] : []
        content {
          consumer_key                 = var.settings.auth_settings_v2.twitter_v2.consumer_key
          consumer_secret_setting_name = var.settings.auth_settings.twitter_v2.consumer_secret_setting_name
        }
      }

      dynamic "login" {
        for_each = try(var.settings.auth_settings_v2.login, {}) != {} ? [1] : []
        content {
          logout_endpoint                   = try(var.settings.auth_settings_v2.login.logout_endpoint, null)
          token_store_enabled               = try(var.settings.auth_settings_v2.login.token_store_enabled, false)
          token_refresh_extension_time      = try(var.settings.auth_settings_v2.login.token_refresh_extension_time, 72)
          token_store_path                  = try(var.settings.auth_settings_v2.login.token_store_path, null)
          token_store_sas_setting_name      = try(var.settings.auth_settings_v2.login.token_store_sas_setting_name, null)
          preserve_url_fragments_for_logins = try(var.settings.auth_settings_v2.login.preserve_url_fragments_for_logins, false)
          allowed_external_redirect_urls    = try(var.settings.auth_settings_v2.login.allowed_external_redirect_urls, null)
          cookie_expiration_convention      = try(var.settings.auth_settings_v2.login.cookie_expiration_convention, null)
          cookie_expiration_time            = try(var.settings.auth_settings_v2.login.cookie_expiration_time, null)
          validate_nonce                    = try(var.settings.auth_settings_v2.login.validate_nonce, true)
          nonce_expiration_time             = try(var.settings.auth_settings_v2.login.nonce_expiration_time, "00:05:00")
        }
      }

    }

  }

  dynamic "backup" {
    for_each = try(var.settings.backup, {}) != {} ? [1] : []
    content {
      name = var.settings.backup.name
      schedule {
        frequency_interval       = var.settings.backup.schedule.frequency_interval
        frequency_unit           = var.settings.backup.schedule.frequency_unit
        keep_at_least_one_backup = try(var.settings.backup.schedule.keep_at_least_one_backup, false)
        retention_period_days    = try(var.settings.backup.schedule.retention_period_days, 30)
        start_time               = try(var.settings.backup.schedule.start_time, null)
      }
      storage_account_url = try(
        var.settings.backup.storage_account_url,
        var.remote_objects.storage_accounts[try(var.settings.backup.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.backup.storage_account.key].primary_blob_connection_string
      )
      enabled = try(var.settings.backup.enabled, true)
    }
  }

  builtin_logging_enabled            = try(var.settings.builtin_logging_enabled, true)
  client_certificate_enabled         = try(var.settings.client_certificate_enabled, false)
  client_certificate_mode            = try(var.settings.client_certificate_mode, null)
  client_certificate_exclusion_paths = try(var.settings.client_certificate_exclusion_paths, null)

  dynamic "connection_string" {
    for_each = try(var.settings.connection_string, {}) != {} ? [1] : []
    content {
      name  = var.settings.connection_string.name
      type  = var.settings.connection_string.type
      value = var.settings.connection_string.value
    }
  }

  daily_memory_time_quota                  = try(var.settings.daily_memory_time_quota, 0)
  enabled                                  = try(var.settings.enabled, true)
  content_share_force_disabled             = try(var.settings.content_share_force_disabled, null)
  functions_extension_version              = try(var.settings.functions_extension_version, null)
  ftp_publish_basic_authentication_enabled = try(var.settings.ftp_publish_basic_authentication_enabled, null)
  https_only                               = try(var.settings.https_only, true)
  public_network_access_enabled            = try(var.settings.public_network_access_enabled, true)
  dynamic "identity" {
    for_each = try(var.settings.identity, {}) != {} ? [1] : []
    content {
      type         = var.settings.identity.type
      identity_ids = concat(local.managed_identities, try(identity.value.identity_ids, []))
    }
  }


  key_vault_reference_identity_id = try(
    var.settings.key_vault_reference_identity_id,
    var.remote_objects.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.key_vault_reference_identity.key].id,
    null
  )

  dynamic "storage_account" {
    for_each = try(var.settings.storage_account, {}) != {} ? [1] : []
    content {
      access_key = try(
        var.settings.storage_account.access_key,
        var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.key].primary_access_key
      )
      account_name = var.settings.storage_account.account_name
      name         = var.settings.storage_account.name
      share_name   = var.settings.storage_account.share_name
      type         = var.settings.storage_account.type
      mount_path   = try(var.settings.storage_account.mount_path, null)
    }
  }

  storage_account_access_key = try(
    var.settings.storage_account_access_key,
    var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.key].primary_access_key
  )

  storage_account_name = try(
    var.settings.storage_account_name,
    var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.key].name
  )

  storage_uses_managed_identity = try(var.settings.storage_uses_managed_identity, false)
  storage_key_vault_secret_id   = try(var.settings.storage_key_vault_secret_id, null)

  tags = local.tags

  virtual_network_subnet_id = coalesce(
    try(var.settings.virtual_network_subnet_id, null),
    try(var.remote_objects.vnets[try(var.settings.virtual_network_subnet.lz_key, var.client_config.landingzone_key)][var.settings.virtual_network_subnet.vnet_key].subnets[var.settings.virtual_network_subnet.subnet_key].id, null)
  )

  vnet_image_pull_enabled                        = try(var.settings.vnet_image_pull_enabled, false)
  webdeploy_publish_basic_authentication_enabled = try(var.settings.webdeploy_publish_basic_authentication_enabled, null)


  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, {}) != {} ? [1] : []
    content {
      create = try(var.settings.timeouts.create, null)
      read   = try(var.settings.timeouts.read, null)
      update = try(var.settings.timeouts.update, null)
      delete = try(var.settings.timeouts.delete, null)
    }

  }








}
