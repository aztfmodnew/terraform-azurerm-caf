module "network_managers" {
  source   = "./modules/networking/network_manager"
  for_each = local.networking.network_managers

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value



  remote_objects = {
    aubscriptions = local.combined_objects_subscriptions
    diagnostics   = local.combined_diagnostics
    vnets         = local.combined_objects_networking
  }
}

output "network_managers" {
  value = module.network_managers
}


module "network_manager_network_groups" {
  source          = "./modules/networking/network_manager/network_group"
  for_each        = local.networking.network_manager_network_groups
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_managers = local.combined_objects_network_managers
  }
}


output "network_manager_network_groups" {
  value = module.network_manager_network_groups
}

module "network_manager_static_members" {
  source          = "./modules/networking/network_manager/static_member"
  for_each        = local.networking.network_manager_static_members
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_groups = local.combined_objects_network_manager_network_groups
    vnets          = local.combined_objects_networking
  }
}

output "network_manager_static_members" {
  value = module.network_manager_static_members
}

module "network_manager_connectivity_configurations" {
  source          = "./modules/networking/network_manager/connectivity_configuration"
  for_each        = local.networking.network_manager_connectivity_configurations
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_managers = local.combined_objects_network_managers
    network_groups   = local.combined_objects_network_manager_network_groups
    vnets            = local.combined_objects_networking
  }
}

output "network_manager_connectivity_configurations" {
  value = module.network_manager_connectivity_configurations
}

module "network_manager_admin_rule_collections" {
  source          = "./modules/networking/network_manager/admin_rule_collection"
  for_each        = local.networking.network_manager_admin_rule_collections
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_groups                = local.combined_objects_network_manager_network_groups
    security_admin_configurations = local.combined_objects_network_manager_security_admin_configurations
  }
}


module "network_manager_admin_rules" {
  source          = "./modules/networking/network_manager/admin_rule"
  for_each        = local.networking.network_manager_admin_rules
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    admin_rule_collections = local.combined_objects_network_manager_admin_rule_collections
  }
}

output "network_manager_admin_rules" {
  value = module.network_manager_admin_rules
}

module "network_manager_deployments" {
  source          = "./modules/networking/network_manager/deployment"
  for_each        = local.networking.network_manager_deployments
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_managers              = local.combined_objects_network_managers
    security_admin_configurations = local.combined_objects_network_manager_security_admin_configurations
    connectivity_configurations   = local.combined_objects_network_manager_connectivity_configurations
  }
}

output "network_manager_deployments" {
  value = module.network_manager_deployments
}

module "network_manager_security_admin_configurations" {
  source          = "./modules/networking/network_manager/security_admin_configuration"
  for_each        = local.networking.network_manager_security_admin_configurations
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
  }
}

output "network_manager_security_admin_configurations" {
  value = module.network_manager_security_admin_configurations
}


module "network_manager_management_group_connections" {
  source          = "./modules/networking/network_manager/management_group_connection"
  for_each        = local.networking.network_manager_management_group_connections
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_managers = local.combined_objects_network_managers
  }
}

output "network_manager_management_group_connections" {
  value = module.network_manager_management_group_connections
}

module "network_manager_scope_connections" {
  source          = "./modules/networking/network_manager/scope_connection"
  for_each        = local.networking.network_manager_scope_connections
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_managers = local.combined_objects_network_managers
  }
}


output "network_manager_scope_connections" {
  value = module.network_manager_scope_connections
}

module "network_manager_subscription_connections" {
  source          = "./modules/networking/network_manager/subscription_connection"
  for_each        = local.networking.network_manager_subscription_connections
  client_config   = local.client_config
  global_settings = local.global_settings
  settings        = each.value
  remote_objects = {
    network_managers = local.combined_objects_network_managers
  }
}

output "network_manager_subscription_connections" {
  value = module.network_manager_subscription_connections
}