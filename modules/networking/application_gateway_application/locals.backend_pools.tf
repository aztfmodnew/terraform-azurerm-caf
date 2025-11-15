locals {
  backend_pools_linux_web_apps = {
    for key, value in try(var.settings.backend_pools, {}) : key => flatten(
      [
        for web_app_key, web_app in try(value.linux_web_apps, {}) : [
          try(var.linux_web_apps[web_app.lz_key][web_app.key].default_hostname, var.linux_web_apps[var.client_config.landingzone_key][web_app.key].default_hostname)
        ]
      ]
    ) if lookup(value, "linux_web_apps", false) != false
  }

  backend_pools_windows_web_apps = {
    for key, value in try(var.settings.backend_pools, {}) : key => flatten(
      [
        for web_app_key, web_app in try(value.windows_web_apps, {}) : [
          try(var.windows_web_apps[web_app.lz_key][web_app.key].default_hostname, var.windows_web_apps[var.client_config.landingzone_key][web_app.key].default_hostname)
        ]
      ]
    ) if lookup(value, "windows_web_apps", false) != false
  }

  # Resolve Storage Account Private Endpoint IPs for backend pools
  # Extracts the first private IP from storage account private endpoints
  backend_pools_storage_accounts = {
    for key, value in try(var.settings.backend_pools, {}) : key => flatten(
      [
        for sa_key, sa_config in try(value.storage_accounts, {}) : [
          try(
            # Try to get the first private IP from the private endpoint output
            # Storage account private_endpoints output format: { pe_key = { private_ip_address = "x.x.x.x", ... } }
            values(var.remote_objects.storage_accounts[try(sa_config.lz_key, var.client_config.landingzone_key)][sa_config.key].private_endpoints)[try(sa_config.private_endpoint_index, 0)].private_ip_address,
            # Fallback: try with explicit private_endpoint_key if provided
            var.remote_objects.storage_accounts[try(sa_config.lz_key, var.client_config.landingzone_key)][sa_config.key].private_endpoints[sa_config.private_endpoint_key].private_ip_address
          )
        ]
      ]
    ) if lookup(value, "storage_accounts", false) != false
  }

  # backend_pools_fqdn = {
  #   for key, value in var.settings.backend_pools : key => flatten(
  #     [
  #       try(value.fqdns, [])
  #     ]
  #   ) if lookup(value, "fqdns", false) != false
  # }

  # backend_pools_vmss = {
  #   for key, value in var.settings : key = > flatten(
  #     [
  #       try(value.backend_pool.vmss,)
  #     ]
  #   )
  # }

  backend_pools = {
    for key, value in try(var.settings.backend_pools, {}) : key => {
      address_pools = join(" ", try(flatten(
        [
          try(local.backend_pools_linux_web_apps[key], []),
          try(local.backend_pools_windows_web_apps[key], []),
          try(local.backend_pools_storage_accounts[key], []),
          try(value.fqdns, []),
          try(value.ip_addresses, [])
        ]
      ), null))
    }
  }
}
