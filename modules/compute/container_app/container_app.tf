resource "azurecaf_name" "ca" {
  name          = var.settings.name
  prefixes      = var.global_settings.prefixes
  resource_type = "azurerm_container_app"
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_container_app" "ca" {
  name                         = azurecaf_name.ca.result
  resource_group_name          = local.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = var.settings.revision_mode
  workload_profile_name        = try(var.settings.workload_profile_name, null)
  max_inactive_revisions       = try(var.settings.max_inactive_revisions, null)
  tags                         = merge(local.tags, try(var.settings.tags, null))

  template {
    termination_grace_period_seconds = try(var.settings.template.termination_grace_period_seconds, null)

    dynamic "init_container" {
      for_each = try(var.settings.template.init_containers, {})

      content {
        name    = init_container.value.name
        image   = init_container.value.image
        args    = try(init_container.value.args, null)
        command = try(init_container.value.command, null)

        dynamic "env" {
          for_each = try(init_container.value.env, {})

          content {
            name        = env.value.name
            secret_name = try(env.value.secret_name, null)
            value       = try(env.value.value, null)
          }
        }

        dynamic "volume_mounts" {
          for_each = try(init_container.value.volume_mounts, {})

          content {
            name     = volume_mounts.value.name
            path     = volume_mounts.value.path
            sub_path = try(volume_mounts.value.sub_path, null)
          }
        }

        cpu                = try(init_container.value.cpu, null)
        memory             = try(init_container.value.memory, null)
        ephemeral_storage  = try(init_container.value.ephemeral_storage, null)
      }
    }

    dynamic "container" {
      for_each = var.settings.template.container

      content {
        name    = container.value.name
        image   = container.value.image
        args    = try(container.value.args, null)
        command = try(container.value.command, null)
        cpu     = container.value.cpu
        memory  = container.value.memory
        ephemeral_storage = try(container.value.ephemeral_storage, null)

        dynamic "env" {
          for_each = try(container.value.env, {})

          content {
            name        = env.value.name
            secret_name = try(env.value.secret_name, null)
            value       = try(env.value.value, null)
          }
        }

        dynamic "liveness_probe" {
          for_each = can(container.value.liveness_probe) ? [container.value.liveness_probe] : []

          content {
            failure_count_threshold          = try(liveness_probe.value.failure_count_threshold, null)
            host                             = try(liveness_probe.value.host, null)
            initial_delay                    = try(liveness_probe.value.initial_delay, null)
            interval_seconds                 = try(liveness_probe.value.interval_seconds, null)
            path                             = try(liveness_probe.value.path, null)
            port                             = liveness_probe.value.port
            termination_grace_period_seconds = try(liveness_probe.value.termination_grace_period_seconds, null)
            timeout                          = try(liveness_probe.value.timeout, null)
            transport                        = liveness_probe.value.transport

            dynamic "header" {
              for_each = can(liveness_probe.value.header) ? [liveness_probe.value.header] : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = can(container.value.readiness_probe) ? [container.value.readiness_probe] : []

          content {
            failure_count_threshold = try(readiness_probe.value.failure_count_threshold, null)
            host                    = try(readiness_probe.value.host, null)
            interval_seconds        = try(readiness_probe.value.interval_seconds, null)
            path                    = try(readiness_probe.value.path, null)
            port                    = readiness_probe.value.port
            success_count_threshold = try(readiness_probe.value.success_count_threshold, null)
            timeout                 = try(readiness_probe.value.timeout, null)
            transport               = readiness_probe.value.transport

            dynamic "header" {
              for_each = can(readiness_probe.value.header) ? [readiness_probe.value.header] : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = can(container.value.startup_probe) ? [container.value.startup_probe] : []

          content {
            failure_count_threshold          = try(startup_probe.value.failure_count_threshold, null)
            host                             = try(startup_probe.value.host, null)
            interval_seconds                 = try(startup_probe.value.interval_seconds, null)
            path                             = try(startup_probe.value.path, null)
            port                             = startup_probe.value.port
            termination_grace_period_seconds = try(startup_probe.value.termination_grace_period_seconds, null)
            timeout                          = try(startup_probe.value.timeout, null)
            transport                        = startup_probe.value.transport

            dynamic "header" {
              for_each = can(startup_probe.value.header) ? [startup_probe.value.header] : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = try(container.value.volume_mounts, {})

          content {
            name       = volume_mounts.value.name
            path       = volume_mounts.value.path
            sub_path   = try(volume_mounts.value.sub_path, null)
          }
        }
      }
    }
    dynamic "azure_queue_scale_rule" {
      for_each = try(var.settings.template.azure_queue_scale_rule, {})
      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = try(azure_queue_scale_rule.value.authentication, [])

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = try(var.settings.template.custom_scale_rule, {})
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata

        dynamic "authentication" {
          for_each = try(custom_scale_rule.value.authentication, {})

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = try(var.settings.template.http_scale_rule, {})
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = try(http_scale_rule.value.authentication, {})

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = try(var.settings.template.tcp_scale_rule, {})
      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = try(tcp_scale_rule.value.authentication, {})

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    min_replicas    = try(var.settings.template.min_replicas, null)
    max_replicas    = try(var.settings.template.max_replicas, null)
    revision_suffix = try(var.settings.template.revision_suffix, null)

    dynamic "volume" {
      for_each = try(var.settings.template.volume, {})

      content {
        name          = volume.value.name
        storage_name  = try(volume.value.storage_name, null)
        storage_type  = try(volume.value.storage_type, "EmptyDir")
        mount_options = try(volume.value.mount_options, null)
      }
    }
  }

  dynamic "ingress" {
    for_each = can(var.settings.ingress) ? [var.settings.ingress] : []

    content {
      allow_insecure_connections = try(ingress.value.allow_insecure_connections, null)
      external_enabled           = try(ingress.value.external_enabled, null)
      exposed_port              = try(ingress.value.exposed_port, null)
      target_port               = ingress.value.target_port
      transport                 = try(ingress.value.transport, "auto")
      client_certificate_mode   = try(ingress.value.client_certificate_mode, null)

      dynamic "cors" {
        for_each = try(ingress.value.cors, null) == null ? [] : [ingress.value.cors]

        content {
          allow_credentials_enabled = try(cors.value.allow_credentials_enabled, false)
          allowed_headers          = try(cors.value.allowed_headers, null)
          allowed_methods          = try(cors.value.allowed_methods, null)
          allowed_origins          = cors.value.allowed_origins
          exposed_headers          = try(cors.value.exposed_headers, null)
          max_age_in_seconds       = try(cors.value.max_age_in_seconds, null)
        }
      }

      dynamic "ip_security_restriction" {
        for_each = try(ingress.value.ip_security_restrictions, [])

        content {
          action           = ip_security_restriction.value.action
          description      = try(ip_security_restriction.value.description, null)
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
        }
      }

      dynamic "traffic_weight" {
        for_each = try(ingress.value.traffic_weight, {})

        content {
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
          percentage      = traffic_weight.value.percentage
        }
      }
    }
  }

  dynamic "dapr" {
    for_each = can(var.settings.dapr) ? [var.settings.dapr] : []

    content {
      app_id       = dapr.value.app_id
      app_port     = try(dapr.value.app_port, null)
      app_protocol = try(dapr.value.app_protocol, "http")
    }
  }

  dynamic "secret" {
    for_each = try(var.settings.secret, {})

    content {
      name                = secret.value.name
      value               = try(secret.value.value, null)
      identity            = try(secret.value.identity, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
    }
  }

  dynamic "identity" {
    for_each = can(var.settings.identity) ? [var.settings.identity] : []

    content {
      type         = var.settings.identity.type
      identity_ids = local.managed_identities
    }
  }

  dynamic "registry" {
    for_each = can(var.settings.registry) ? [var.settings.registry] : []

    content {
      server               = registry.value.server
      identity             = can(registry.value.identity.key) ? var.combined_resources.managed_identities[try(registry.value.identity.lz_key, var.client_config.landingzone_key)][registry.value.identity.key].id : try(registry.value.identity.id, null)
      username             = try(registry.value.username, null)
      password_secret_name = try(registry.value.password_secret_name, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
