locals {
  os_type = lower(var.settings.os_type)
  # Generate SSH Keys only if a public one is not provided
  create_sshkeys = local.os_type == "linux" && try(var.settings.public_key_pem_file == "", true)
  application_gateway_backend_address_pool_ids = flatten([
    for nic, nic_value in var.settings.network_interfaces : [
      for appgw, appgw_value in try(nic_value.appgw_backend_pools, {}) : [
        for pool_name in appgw_value.pool_names : [
          try(var.application_gateways[try(var.client_config.landingzone_key, appgw_value.lz_key)][appgw_value.appgw_key].backend_address_pools[pool_name], null)
        ]
      ]
    ]
  ])

  application_security_group_ids = flatten([
    for nic, nic_value in var.settings.network_interfaces : [
      for asg, asg_value in try(nic_value.application_security_groups, {}) : [
        try(var.application_security_groups[var.client_config.landingzone_key][asg_value.asg_key].id, var.application_security_groups[asg_value.lz_key][asg_value.asg_key].id)
      ]
    ]
  ])

}


