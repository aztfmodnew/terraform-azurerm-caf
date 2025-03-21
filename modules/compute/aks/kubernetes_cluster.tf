## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
### Naming convention

resource "azurecaf_name" "aks" {
  name          = var.settings.name
  resource_type = "azurerm_kubernetes_cluster"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurecaf_name" "rg_node" {
  name          = var.settings.node_resource_group_name
  resource_type = "azurerm_resource_group"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

### AKS cluster resource


# trunk-ignore(trivy/AVD-AZU-0040)
# trunk-ignore(trivy/AVD-AZU-0041)
# trunk-ignore(trivy/AVD-AZU-0043)
resource "azurerm_kubernetes_cluster" "aks" {
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  name                = azurecaf_name.aks.result
  location            = local.location
  resource_group_name = local.resource_group_name
  default_node_pool {
    name                          = var.settings.default_node_pool.name //azurecaf_name.default_node_pool.result
    vm_size                       = var.settings.default_node_pool.vm_size
    capacity_reservation_group_id = try(var.settings.default_node_pool.capacity_reservation_group_id, null)
    auto_scaling_enabled          = try(var.settings.default_node_pool.auto_scaling_enabled, false)
    host_encryption_enabled       = try(var.settings.default_node_pool.host_encryption_enabled, false)
    node_public_ip_enabled        = try(var.settings.default_node_pool.node_public_ip_enabled, false)
    gpu_instance                  = try(var.settings.default_node_pool.gpu_instance, null)
    host_group_id                 = try(var.settings.default_node_pool.host_group_id, null)
    dynamic "kubelet_config" {
      for_each = try(var.settings.default_node_pool.kubelet_config, null) == null ? [] : [var.settings.default_node_pool.kubelet_config]
      content {
        allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
        container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
        container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
        cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
        cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
        cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
        image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
        image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
        pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
        topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
      }
    }
    dynamic "linux_os_config" {
      for_each = try(var.settings.default_node_pool.linux_os_config, null) == null ? [] : [var.settings.default_node_pool.linux_os_config]
      content {
        swap_file_size_mb = try(linux_os_config.value.allowed_unsafe_sysctls, null)
        dynamic "sysctl_config" {
          for_each = try(linux_os_config.value.sysctl_config, null) == null ? [] : [linux_os_config.value.sysctl_config]
          content {
            fs_aio_max_nr                      = try(sysctl_config.value.fs_aio_max_nr, null)
            fs_file_max                        = try(sysctl_config.value.fs_file_max, null)
            fs_inotify_max_user_watches        = try(sysctl_config.value.fs_inotify_max_user_watches, null)
            fs_nr_open                         = try(sysctl_config.value.fs_nr_open, null)
            kernel_threads_max                 = try(sysctl_config.value.kernel_threads_max, null)
            net_core_netdev_max_backlog        = try(sysctl_config.value.net_core_netdev_max_backlog, null)
            net_core_optmem_max                = try(sysctl_config.value.net_core_optmem_max, null)
            net_core_rmem_default              = try(sysctl_config.value.net_core_rmem_default, null)
            net_core_rmem_max                  = try(sysctl_config.value.net_core_rmem_max, null)
            net_core_somaxconn                 = try(sysctl_config.value.net_core_somaxconn, null)
            net_core_wmem_default              = try(sysctl_config.value.net_core_wmem_default, null)
            net_core_wmem_max                  = try(sysctl_config.value.net_core_wmem_max, null)
            net_ipv4_ip_local_port_range_max   = try(sysctl_config.value.net_ipv4_ip_local_port_range_max, null)
            net_ipv4_ip_local_port_range_min   = try(sysctl_config.value.net_ipv4_ip_local_port_range_min, null)
            net_ipv4_neigh_default_gc_thresh1  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh1, null)
            net_ipv4_neigh_default_gc_thresh2  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh2, null)
            net_ipv4_neigh_default_gc_thresh3  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh3, null)
            net_ipv4_tcp_fin_timeout           = try(sysctl_config.value.net_ipv4_tcp_fin_timeout, null)
            net_ipv4_tcp_keepalive_intvl       = try(sysctl_config.value.net_ipv4_tcp_keepalive_intvl, null)
            net_ipv4_tcp_keepalive_probes      = try(sysctl_config.value.net_ipv4_tcp_keepalive_probes, null)
            net_ipv4_tcp_keepalive_time        = try(sysctl_config.value.net_ipv4_tcp_keepalive_time, null)
            net_ipv4_tcp_max_syn_backlog       = try(sysctl_config.value.net_ipv4_tcp_max_syn_backlog, null)
            net_ipv4_tcp_max_tw_buckets        = try(sysctl_config.value.net_ipv4_tcp_max_tw_buckets, null)
            net_ipv4_tcp_tw_reuse              = try(sysctl_config.value.net_ipv4_tcp_tw_reuse, null)
            net_netfilter_nf_conntrack_buckets = try(sysctl_config.value.net_netfilter_nf_conntrack_buckets, null)
            net_netfilter_nf_conntrack_max     = try(sysctl_config.value.net_netfilter_nf_conntrack_max, null)
            vm_max_map_count                   = try(sysctl_config.value.vm_max_map_count, null)
            vm_swappiness                      = try(sysctl_config.value.vm_swappiness, null)
            vm_vfs_cache_pressure              = try(sysctl_config.value.vm_vfs_cache_pressure, null)
          }
        }
        transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
        transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
      }
    }
    fips_enabled      = try(var.settings.default_node_pool.fips_enabled, null)
    kubelet_disk_type = try(var.settings.default_node_pool.kubelet_disk_type, null)
    max_pods          = try(var.settings.default_node_pool.max_pods, 30)

    dynamic "node_network_profile" {
      for_each = try(var.settings.default_node_pool.node_network_profile, null) == null ? [] : [var.settings.default_node_pool.node_network_profile]

      content {
        dynamic "allowed_host_ports" {
          for_each = try(node_network_profile.value.allowed_hosts_ports, null)
          content {
            port_start = allowed_hosts_ports.value.port_start
            port_end   = allowed_hosts_ports.value.port_end
            protocol   = allowed_hosts_ports.value.protocol
          }
        }
        application_security_group_ids = try(node_network_profile.value.application_security_group_ids, null)
        node_public_ip_tags            = try(node_network_profile.value.node_public_ip_tags, null)
      }
    }
    node_public_ip_prefix_id     = try(var.settings.default_node_pool.node_public_ip_prefix_id, null)
    node_labels                  = try(var.settings.default_node_pool.node_labels, null)
    only_critical_addons_enabled = try(var.settings.default_node_pool.only_critical_addons_enabled, false)
    orchestrator_version         = try(var.settings.default_node_pool.orchestrator_version, try(var.settings.kubernetes_version, null))
    os_disk_size_gb              = try(var.settings.default_node_pool.os_disk_size_gb, null)
    os_disk_type                 = try(var.settings.default_node_pool.os_disk_type, null)
    os_sku                       = try(var.settings.default_node_pool.os_sku, null)
    pod_subnet_id                = can(var.settings.default_node_pool.pod_subnet_key) == false || can(var.settings.default_node_pool.pod_subnet.key) == false || can(var.settings.default_node_pool.pod_subnet_id) || can(var.settings.default_node_pool.pod_subnet.resource_id) ? try(var.settings.default_node_pool.pod_subnet_id, var.settings.default_node_pool.pod_subnet.resource_id, null) : var.remote_objects.vnets[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.vnet_key].subnets[try(var.settings.default_node_pool.pod_subnet_key, var.settings.default_node_pool.pod_subnet.key)].id
    proximity_placement_group_id = try(var.settings.default_node_pool.proximity_placement_group_id, null)
    scale_down_mode              = try(var.settings.default_node_pool.scale_down_mode, null)
    snapshot_id                  = try(var.settings.default_node_pool.snapshot_id, null)
    temporary_name_for_rotation  = try(var.settings.default_node_pool.temporary_name_for_rotation, null)
    type                         = try(var.settings.default_node_pool.type, "VirtualMachineScaleSets")
    tags                         = merge(try(var.settings.default_node_pool.tags, {}), local.tags)
    ultra_ssd_enabled            = try(var.settings.default_node_pool.ultra_ssd_enabled, false)
    dynamic "upgrade_settings" {
      for_each = try(var.settings.default_node_pool.upgrade_settings, null) == null ? [] : [var.settings.default_node_pool.upgrade_settings]
      content {
        max_surge = upgrade_settings.value.max_surge
      }
    }
    vnet_subnet_id   = can(var.settings.default_node_pool.vnet_subnet_id) || can(var.settings.default_node_pool.subnet.resource_id) ? try(var.settings.default_node_pool.vnet_subnet_id, var.settings.default_node_pool.subnet.resource_id) : var.remote_objects.vnets[try(var.settings.vnet.lz_key, var.settings.lz_key, var.client_config.landingzone_key)][try(var.settings.vnet.key, var.settings.vnet_key)].subnets[try(var.settings.default_node_pool.subnet_key, var.settings.default_node_pool.subnet.key)].id
    workload_runtime = try(var.settings.default_node_pool.workload_runtime, null)
    zones            = try(var.settings.default_node_pool.zones, var.settings.default_node_pool.availability_zones, null)
    max_count        = try(var.settings.default_node_pool.auto_scaling_enabled, false) == false ? null : try(var.settings.default_node_pool.max_count, null)
    min_count        = try(var.settings.default_node_pool.auto_scaling_enabled, false) == false ? null : try(var.settings.default_node_pool.min_count, null)
    node_count       = try(var.settings.default_node_pool.node_count, null)
  }
  dns_prefix                 = try(var.settings.dns_prefix, try(var.settings.dns_prefix_private_cluster, random_string.prefix.result))
  dns_prefix_private_cluster = try(var.settings.dns_prefix_private_cluster, null)
  dynamic "aci_connector_linux" {
    for_each = try(var.settings.aci_connector_linux, null) == null ? [] : [var.settings.aci_connector_linux]

    content {
      subnet_name = aci_connector_linux.value.subnet_name
    }
  }
  automatic_upgrade_channel = try(var.settings.automatic_upgrade_channel, null)
  dynamic "api_server_access_profile" {
    for_each = try(var.settings.api_server_access_profile, null) == null ? [] : [var.settings.api_server_access_profile]

    content {
      authorized_ip_ranges = try(api_server_access_profile.value.authorized_ip_ranges, null)
    }

  }

  dynamic "auto_scaler_profile" {
    for_each = try(var.settings.auto_scaler_profile, null) == null ? [] : [var.settings.auto_scaler_profile]

    content {
      balance_similar_node_groups      = try(auto_scaler_profile.value.balance_similar_node_groups, null)
      expander                         = try(auto_scaler_profile.value.expander, null)
      max_graceful_termination_sec     = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time       = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes                = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage           = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay           = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add       = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete    = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure   = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scan_interval                    = try(auto_scaler_profile.value.scan_interval, null)
      scale_down_unneeded              = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready               = try(auto_scaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold = try(auto_scaler_profile.value.scale_down_utilization_threshold, null)
      empty_bulk_delete_max            = try(auto_scaler_profile.value.empty_bulk_delete_max, null)
      skip_nodes_with_local_storage    = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods      = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  #Enabled RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = try(var.settings.azure_active_directory_role_based_access_control, null) == null ? [] : [var.settings.azure_active_directory_role_based_access_control]

    content {
      tenant_id              = try(azure_active_directory_role_based_access_control.value.tenant_id, null)
      azure_rbac_enabled     = try(azure_active_directory_role_based_access_control.value.enabled, true)
      admin_group_object_ids = try(azure_active_directory_role_based_access_control.value.admin_group_object_ids, var.admin_group_object_ids, [])
    }
  }
  azure_policy_enabled = try(var.settings.azure_policy_enabled, null)
  dynamic "confidential_computing" {
    for_each = try(var.settings.confidential_computing, null) == null ? [] : [var.settings.confidential_computing]

    content {
      sgx_quote_helper_enabled = try(confidential_computing.value.sgx_quote_helper_enabled, null)
    }

  }
  cost_analysis_enabled            = try(var.settings.cost_analysis_enabled, false)
  disk_encryption_set_id           = try(var.settings.disk_encryption_set_id, null)
  edge_zone                        = try(var.settings.edge_zone, null)
  http_application_routing_enabled = try(var.settings.http_application_routing_enabled, null)
  dynamic "http_proxy_config" {
    for_each = try(var.settings.http_proxy_config, null) == null ? [] : [var.settings.http_proxy_config]

    content {
      http_proxy  = try(http_proxy_config.value.http_proxy, null)
      https_proxy = try(http_proxy_config.value.https_proxy, null)
      no_proxy    = try(http_proxy_config.value.no_proxy, null)
      trusted_ca  = try(http_proxy_config.value.trusted_ca, null)
    }
  }

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = var.settings.identity.type
      identity_ids = lower(var.settings.identity.type) == "userassigned" ? can(var.settings.identity.user_assigned_identity_id) ? [var.settings.identity.user_assigned_identity_id] : [var.remote_objects.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.identity.managed_identity_key].id] : null
    }
  }

  image_cleaner_enabled        = try(var.settings.image_cleaner_enabled, null)
  image_cleaner_interval_hours = try(var.settings.image_cleaner_interval_hours, null)
  dynamic "ingress_application_gateway" {
    for_each = try(var.settings.ingress_application_gateway, null) == null ? [] : [var.settings.ingress_application_gateway]
    content {
      gateway_name = try(ingress_application_gateway.value.gateway_name, null)
      gateway_id   = try(ingress_application_gateway.value.gateway_id, try(var.application_gateway.id, null))
      subnet_cidr  = try(ingress_application_gateway.value.subnet_cidr, null)
      subnet_id    = try(ingress_application_gateway.value.subnet_id, null)
    }
  }

  dynamic "key_management_service" {
    for_each = try(var.settings.key_management_service, null) == null ? [] : [var.settings.key_management_service]
    content {
      key_vault_key_id         = key_management_service.value.key_vault_key_id
      key_vault_network_access = try(key_management_service.value.key_vault_network_access, null)
      #secret_rotation_enabled  = try(key_management_service.value.secret_rotation_enabled, null) # legacy?
      #secret_rotation_interval = try(key_management_service.value.secret_rotation_enabled, null) # legacy?
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = try(var.settings.key_vault_secrets_provider, null) == null ? [] : [var.settings.key_vault_secrets_provider]
    content {
      secret_rotation_enabled  = try(key_vault_secrets_provider.value.secret_rotation_enabled, null)
      secret_rotation_interval = try(key_vault_secrets_provider.value.secret_rotation_interval, null)
    }
  }

  dynamic "kubelet_identity" {
    for_each = try(var.settings.kubelet_identity, null) == null ? [] : [var.settings.kubelet_identity]
    content {
      client_id                 = can(kubelet_identity.value.client_id) ? kubelet_identity.value.client_id : var.remote_objects.managed_identities[try(var.settings.kubelet_identity.lz_key, var.client_config.landingzone_key)][var.settings.kubelet_identity.managed_identity_key].client_id
      object_id                 = can(kubelet_identity.value.object_id) ? kubelet_identity.value.object_id : var.remote_objects.managed_identities[try(var.settings.kubelet_identity.lz_key, var.client_config.landingzone_key)][var.settings.kubelet_identity.managed_identity_key].principal_id
      user_assigned_identity_id = can(kubelet_identity.value.user_assigned_identity_id) ? kubelet_identity.value.user_assigned_identity_id : var.remote_objects.managed_identities[try(var.settings.kubelet_identity.lz_key, var.client_config.landingzone_key)][var.settings.kubelet_identity.managed_identity_key].id
    }
  }

  kubernetes_version = try(var.settings.kubernetes_version, null)

  dynamic "linux_profile" {
    for_each = try(var.settings.linux_profile, null) == null ? [] : [var.settings.linux_profile]
    content {
      admin_username = try(var.settings.linux_profile.admin_username, null)
      dynamic "ssh_key" {
        for_each = try(var.settings.linux_profile.ssh_key, null) == null ? [] : [var.settings.linux_profile.ssh_key]
        content {
          key_data = try(var.settings.linux_profile.ssh_key.key_data, null)
        }
      }
    }
  }

  local_account_disabled = try(var.settings.local_account_disabled, false)

  dynamic "maintenance_window" {
    for_each = try(var.settings.maintenance_window, null) == null ? [] : [var.settings.maintenance_window]
    content {
      dynamic "allowed" {
        for_each = try(var.settings.maintenance_window.allowed, null)
        content {
          day   = var.settings.maintenance_window.allowed.day
          hours = var.settings.maintenance_window.allowed.hours
        }
      }
      dynamic "not_allowed" {
        for_each = try(var.settings.maintenance_window.not_allowed, null)
        content {
          end   = var.settings.maintenance_window.not_allowed.end
          start = var.settings.maintenance_window.not_allowed.start
        }
      }
    }
  }
  dynamic "maintenance_window_auto_upgrade" {
    for_each = try(var.settings.maintenance_window_auto_upgrade, null) == null ? [] : [var.settings.maintenance_window_auto_upgrade]
    content {
      frequency    = maintenance_window_auto_upgrade.frequency
      interval     = maintenance_window_auto_upgrade.interval
      duration     = maintenance_window_auto_upgrade.duration
      day_of_week  = try(maintenance_window_auto_upgrade.day_of_week, null)
      day_of_month = try(maintenance_window_auto_upgrade.day_of_month, null)
      week_index   = try(maintenance_window_auto_upgrade.week_index, null)
      start_time   = try(maintenance_window_auto_upgrade.start_time, null)
      utc_offset   = try(maintenance_window_auto_upgrade.utc_offset, null)
      start_date   = try(maintenance_window_auto_upgrade.start_date, null)
      dynamic "not_allowed" {
        for_each = try(var.settings.maintenance_window_auto_upgrade.maintenance_window_auto_upgrade.not_allowed, null) == null ? [] : [var.settings.maintenance_window_auto_upgrade.not_allowed]
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }

    }

  }

  dynamic "maintenance_window_node_os" {
    for_each = try(var.settings.maintenance_window_node_os, null) == null ? [] : [var.settings.maintenance_window_node_os]
    content {
      frequency    = var.settings.maintenance_window_node_os.frequency
      interval     = var.settings.maintenance_window_node_os.interval
      duration     = var.settings.maintenance_window_node_os.duration
      day_of_week  = try(var.settings.maintenance_window_node_os.day_of_week, null)
      day_of_month = try(var.settings.maintenance_window_node_os.day_of_month, null)
      week_index   = try(var.settings.maintenance_window_node_os.week_index, null)
      start_time   = try(var.settings.maintenance_window_node_os.start_time, null)
      utc_offset   = try(var.settings.maintenance_window_node_os.utc_offset, null)
      start_date   = try(var.settings.maintenance_window_node_os.start_date, null)
      dynamic "not_allowed" {
        for_each = try(var.settings.maintenance_window_node_os.not_allowed, null)
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }

    }

  }

  dynamic "microsoft_defender" {
    for_each = try(var.settings.microsoft_defender, null) == null ? [] : [var.settings.microsoft_defender]

    content {
      log_analytics_workspace_id = can(microsoft_defender.value.log_analytics_workspace_id) ? microsoft_defender.value.log_analytics_workspace_id : var.remote_objects.diagnostics.log_analytics[microsoft_defender.value.log_analytics_key].id
    }
  }

  dynamic "monitor_metrics" {
    for_each = try(var.settings.monitor_metrics, null) == null ? [] : [var.settings.monitor_metrics]

    content {
      annotations_allowed = try(monitor_metrics.value.annotations_allowed, null)
      labels_allowed      = try(monitor_metrics.value.labels_allowed, null)
    }

  }



  dynamic "network_profile" {
    for_each = try(var.settings.network_profile[*], {})
    content {
      network_plugin      = try(network_profile.value.network_plugin, null)
      network_mode        = try(network_profile.value.network_mode, null)
      network_policy      = try(network_profile.value.network_policy, "azure")
      dns_service_ip      = try(network_profile.value.dns_service_ip, null)
      outbound_type       = try(network_profile.value.outbound_type, null)
      pod_cidr            = try(network_profile.value.pod_cidr, null)
      service_cidr        = try(network_profile.value.service_cidr, null)
      service_cidrs       = try(network_profile.value.network_cidrs, null)
      load_balancer_sku   = try(network_profile.value.load_balancer_sku, null)
      network_plugin_mode = try(network_profile.value.network_plugin_mode, null)
      ip_versions         = try(network_profile.value.ip_versions, null)

      dynamic "load_balancer_profile" {
        for_each = try(network_profile.value.load_balancer_profile[*], {})
        content {
          idle_timeout_in_minutes     = try(load_balancer_profile.value.idle_timeout_in_minutes, null)
          managed_outbound_ip_count   = try(load_balancer_profile.value.managed_outbound_ip_count, null)
          managed_outbound_ipv6_count = try(load_balancer_profile.value.managed_outbound_ipv6_count, null)
          outbound_ip_address_ids     = try(load_balancer_profile.value.outbound_ip_address_ids, null)
          outbound_ip_prefix_ids      = try(load_balancer_profile.value.outbound_ip_prefix_ids, null)
          outbound_ports_allocated    = try(load_balancer_profile.value.outbound_ports_allocated, null)
        }
      }
    }
  }

  /*
node_os_upgrade_channel - (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None. Defaults to NodeImage.
Note:
node_os_upgrade_channel must be set to NodeImage if automatic_upgrade_channel has been set to node-image
*/
  node_os_upgrade_channel = try(try(var.settings.automatic_upgrade_channel, null) == "node-image" ? "NodeImage" : try(var.settings.node_os_upgrade_channel, null), null)
  node_resource_group     = azurecaf_name.rg_node.result
  oidc_issuer_enabled     = try(var.settings.oidc_issuer_enabled, null)
  dynamic "oms_agent" {
    for_each = try(var.settings.oms_agent, null) == null ? [] : [var.settings.oms_agent]
    content {
      log_analytics_workspace_id      = can(oms_agent.value.log_analytics_workspace_id) ? oms_agent.value.log_analytics_workspace_id : var.remote_objects.diagnostics.log_analytics[oms_agent.value.log_analytics_key].id
      msi_auth_for_monitoring_enabled = try(oms_agent.value.msi_auth_for_monitoring_enabled, null)
    }
  }
  open_service_mesh_enabled           = try(var.settings.open_service_mesh_enabled, null)
  private_cluster_enabled             = try(var.settings.private_cluster_enabled, null)
  private_dns_zone_id                 = try(var.remote_objects.private_dns_zone_id, var.settings.private_dns_zone_id, null)
  private_cluster_public_fqdn_enabled = try(var.settings.private_cluster_public_fqdn_enabled, null)

  dynamic "service_mesh_profile" {
    for_each = try(var.settings.service_mesh_profile[*], {})
    content {
      mode                             = try(service_mesh_profile.value.mode, null)
      internal_ingress_gateway_enabled = try(service_mesh_profile.value.internal_ingress_gateway_enabled, null)
      external_ingress_gateway_enabled = try(service_mesh_profile.value.external_ingress_gateway_enabled, null)
      revisions                        = try(service_mesh_profile.value.revisions, null)
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = try(var.settings.workload_autoscaler_profile[*], {})
    content {
      keda_enabled = try(workload_autoscaler_profile.value.keda_enabled, null)
    }
  }

  workload_identity_enabled = try(var.settings.workload_identity_enabled, null)


  role_based_access_control_enabled = try(var.settings.role_based_access_control_enabled, true)

  run_command_enabled = try(var.settings.run_command_enabled, null)

  dynamic "service_principal" {
    for_each = try(var.settings.service_principal, null) == null ? [] : [var.settings.service_principal]
    content {
      client_id     = var.settings.service_principal.client_id
      client_secret = var.settings.service_principal.client_secret
    }
  }

  sku_tier = try(var.settings.sku_tier, null)

  support_plan = try(var.settings.support_plan, null)

  tags = merge(local.tags, lookup(var.settings, "tags", {}))

  dynamic "storage_profile" {
    for_each = try(var.settings.storage_profile[*], {})
    content {
      blob_driver_enabled         = try(storage_profile.value.blob_driver_enabled, null)
      disk_driver_enabled         = try(storage_profile.value.disk_driver_enabled, null)
      file_driver_enabled         = try(storage_profile.value.file_driver_enabled, null)
      snapshot_controller_enabled = try(storage_profile.value.snapshot_controller_enabled, null)
    }
  }

  dynamic "web_app_routing" {
    for_each = try(var.settings.web_app_routing[*], {})

    content {
      dns_zone_ids = try(web_app_routing.value.dns_zone_ids, null)
    }
  }

  dynamic "windows_profile" {
    for_each = try(var.settings.windows_profile[*], {})
    content {
      admin_username = var.settings.windows_profile.admin_username
      admin_password = var.settings.windows_profile.admin_password
      license        = try(var.settings.windows_profile.license, null)
      dynamic "gmsa" {
        for_each = try(windows_profile.gmsa[*], {})
        content {
          dns_server  = try(gmsa.value.dns_server, null)
          root_domain = try(gmsa.value.root_domain, null)
        }
      }
    }
  }
}



