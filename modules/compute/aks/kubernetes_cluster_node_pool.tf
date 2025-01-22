## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
### Naming convention

resource "azurecaf_name" "default_node_pool" {
  name          = var.settings.default_node_pool.name
  resource_type = "aks_node_pool_linux"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

#
# Node pools
#

resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  for_each = try(var.settings.node_pools, {})

  name                          = each.value.name
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.aks.id
  vm_size                       = each.value.vm_size
  capacity_reservation_group_id = try(each.value.capacity_reservation_group_id, null)
  zones                         = try(each.value.zones, each.value.availability_zones, null)
  auto_scaling_enabled          = try(each.value.auto_scaling_enabled, false)
  host_encryption_enabled       = try(each.value.host_encryption_enabled, false)
  node_public_ip_enabled        = try(each.value.node_public_ip_enabled, false)
  eviction_policy               = try(each.value.eviction_policy, null)
  host_group_id                 = try(each.value.host_group_id, null)

  dynamic "kubelet_config" {
    for_each = try(each.value.kubelet_config, null) == null ? [] : [1]
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
    for_each = try(each.value.linux_os_config, null) == null ? [] : [1]
    content {
      swap_file_size_mb = try(linux_os_config.value.swap_file_size_mb, null)
      dynamic "sysctl_config" {
        for_each = try(linux_os_config.value.sysctl_config, null) == null ? [] : [1]
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

  fips_enabled      = try(each.value.fips_enabled, false)
  kubelet_disk_type = try(each.value.kubelet_disk_type, null)
  max_pods          = try(each.value.max_pods, null)

  dynamic "node_network_profile" {
    for_each = try(each.value.node_network_profile, null) == null ? [] : [1]
    content {
      node_public_ip_tags = try(node_network_profile.value.node_public_ip_tags, null)
    }
  }

  mode                         = try(each.value.mode, "User")
  node_labels                  = try(each.value.node_labels, null)
  node_public_ip_prefix_id     = try(each.value.node_public_ip_prefix_id, null)
  node_taints                  = try(each.value.node_taints, null)
  orchestrator_version         = try(each.value.orchestrator_version, try(var.settings.kubernetes_version, null))
  os_disk_size_gb              = try(each.value.os_disk_size_gb, null)
  os_disk_type                 = try(each.value.os_disk_type, null)
  pod_subnet_id                = can(each.value.pod_subnet_key) == false || can(each.value.pod_subnet.key) == false || can(each.value.pod_subnet_id) || can(each.value.pod_subnet.resource_id) ? try(each.value.pod_subnet_id, each.value.pod_subnet.resource_id, null) : var.remote_objects.vnets[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.vnet_key].subnets[try(each.value.pod_subnet.key, each.value.pod_subnet_key)].id
  os_sku                       = try(each.value.os_sku, null)
  os_type                      = try(each.value.os_type, null)
  priority                     = try(each.value.priority, null)
  proximity_placement_group_id = try(each.value.proximity_placement_group_id, null)
  spot_max_price               = try(each.value.spot_max_price, null)
  tags                         = merge(try(var.settings.default_node_pool.tags, {}), try(each.value.tags, {}))
  scale_down_mode              = try(each.value.scale_down_mode, null)
  ultra_ssd_enabled            = try(each.value.ultra_ssd_enabled, false)

  dynamic "upgrade_settings" {
    for_each = try(each.value.upgrade_settings, null) == null ? [] : [1]
    content {
      drain_timeout_in_minutes      = upgrade_settings.value.drain_timeout_in_minutes
      node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
      max_surge                     = upgrade_settings.value.max_surge
    }
  }

  vnet_subnet_id = can(each.value.subnet.resource_id) || can(each.value.vnet_subnet_id) ? try(each.value.subnet.resource_id, each.value.vnet_subnet_id) : var.remote_objects.vnets[try(var.settings.vnet.lz_key, var.settings.lz_key, var.client_config.landingzone_key)][try(var.settings.vnet.key, var.settings.vnet_key)].subnets[try(each.value.subnet.key, each.value.subnet_key)].id

  dynamic "windows_profile" {
    for_each = try(each.value.windows_profile, null) == null ? [] : [1]
    content {
      outbound_nat_enabled = try(windows_profile.value.outbound_nat_enabled, null)
    }
  }

  workload_runtime = try(each.value.workload_runtime, null)

  max_count  = try(each.value.max_count, null)
  min_count  = try(each.value.min_count, null)
  node_count = try(each.value.node_count, null)

}
