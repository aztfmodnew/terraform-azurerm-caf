locals {
  # Support for Linux Web Apps
  backend_pools_linux_web_apps = {
    for agw_config_key, value in var.application_gateway_applications : agw_config_key => flatten(
      [
        for app_key, app in try(value.backend_pool.linux_web_apps, {}) : [
          try(var.linux_web_apps[app.lz_key][app.key].default_site_hostname, var.linux_web_apps[var.client_config.landingzone_key][app.key].default_site_hostname)
        ]
      ]
    ) if lookup(value, "backend_pool", false) != false
  }

  # Support for Windows Web Apps
  backend_pools_windows_web_apps = {
    for agw_config_key, value in var.application_gateway_applications : agw_config_key => flatten(
      [
        for app_key, app in try(value.backend_pool.windows_web_apps, {}) : [
          try(var.windows_web_apps[app.lz_key][app.key].default_site_hostname, var.windows_web_apps[var.client_config.landingzone_key][app.key].default_site_hostname)
        ]
      ]
    ) if lookup(value, "backend_pool", false) != false
  }

  backend_pools_fqdn = {
    for key, value in var.application_gateway_applications : key => flatten(
      [
        try(value.backend_pool.fqdns, [])
      ]
    ) if lookup(value, "backend_pool", false) != false
  }

  # backend_pools_vmss = {
  #   for key, value in var.application_gateway_applications : key = > flatten(
  #     [
  #       try(value.backend_pool.vmss,)
  #     ]
  #   )
  # }

  backend_pools = {
    for key, value in var.application_gateway_applications : key => {
      name = try(value.backend_pool.name, value.name)
      fqdns = try(flatten(
        [
          local.backend_pools_linux_web_apps[key],
          local.backend_pools_windows_web_apps[key],
          local.backend_pools_fqdn[key]
        ]
      ), null)
      ip_addresses = try(value.backend_pool.ip_addresses, null)
    } if try(value.type, null) != "redirect"
  }
}
