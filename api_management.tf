module "api_management" {
  source   = "./modules/apim/api_management"
  for_each = local.apim.api_management

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  vnets               = local.combined_objects_networking
  public_ip_addresses = local.combined_objects_public_ip_addresses
  private_endpoints   = try(each.value.private_endpoints, {})
  private_dns         = local.combined_objects_private_dns
  resource_groups     = local.combined_objects_resource_groups
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))]
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : null
  location            = try(local.global_settings.regions[each.value.region], null)

  remote_objects = {
    resource_group     = local.combined_objects_resource_groups
    managed_identities = local.combined_objects_managed_identities
  }
}
output "api_management" {
  value     = module.api_management
  sensitive = true
}

module "api_management_diagnostics" {
  source   = "./modules/diagnostics"
  for_each = local.apim.api_management

  resource_id       = module.api_management[each.key].id
  resource_location = module.api_management[each.key].location
  diagnostics       = local.combined_diagnostics
  profiles          = try(each.value.diagnostic_profiles, {})
}

output "api_management_diagnostics" {
  value = module.api_management_diagnostics
}

module "api_management_api" {
  source   = "./modules/apim/api_management_api"
  for_each = local.apim.api_management_api

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_api" {
  value = module.api_management_api
}

module "api_management_logger" {
  source     = "./modules/apim/api_management_logger"
  depends_on = [time_sleep.azurerm_role_assignment_for]
  for_each   = local.apim.api_management_logger

  global_settings = local.global_settings
  client_config   = local.client_config
  cloud           = local.cloud
  settings        = each.value

  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name
  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name

  remote_objects = {
    resource_group                 = local.combined_objects_resource_groups
    api_management                 = local.combined_objects_api_management
    application_insights           = local.combined_objects_application_insights
    event_hub_namespaces           = local.combined_objects_event_hub_namespaces
    event_hubs                     = local.combined_objects_event_hubs
    event_hub_auth_rules           = local.combined_objects_event_hub_auth_rules
    event_hub_namespace_auth_rules = local.combined_objects_event_hub_namespace_auth_rules
    managed_identities             = local.combined_objects_managed_identities
  }
}
output "api_management_logger" {
  value = module.api_management_logger
}
module "api_management_api_diagnostic" {
  source   = "./modules/apim/api_management_api_diagnostic"
  for_each = local.apim.api_management_api_diagnostic

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_logger_id = try(each.value.api_management_logger.id, null) != null ? each.value.api_management_logger.id : local.combined_objects_api_management_logger[coalesce(try(each.value.api_management_logger.lz_key, null), local.client_config.landingzone_key)][each.value.api_management_logger.key].id
  api_management_name      = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name      = try(each.value.resource_group.name, null) != null ? each.value.resource_group.name : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name
  api_name                 = try(each.value.api.name, null) != null ? each.value.api.name : local.combined_objects_api_management_api[coalesce(try(each.value.api.lz_key, null), local.client_config.landingzone_key)][each.value.api.key].name

  remote_objects = {
    #api_management_logger = local.combined_objects_api_management_logger
    #api_management        = local.combined_objects_api_management
    #resource_group        = local.combined_objects_resource_groups
  }
}
output "api_management_api_diagnostic" {
  value = module.api_management_api_diagnostic
}
module "api_management_api_operation" {
  source   = "./modules/apim/api_management_api_operation"
  for_each = local.apim.api_management_api_operation

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_name            = try(each.value.api.name, null) != null ? each.value.api.name : local.combined_objects_api_management_api[coalesce(try(each.value.api.lz_key, null), local.client_config.landingzone_key)][each.value.api.key].name
  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_api_operation" {
  value = module.api_management_api_operation
}

module "api_management_backend" {
  source   = "./modules/apim/api_management_backend"
  for_each = local.apim.api_management_backend

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_backend" {
  value = module.api_management_backend
}

module "api_management_ai_backend" {
  source   = "./modules/apim/api_management_ai_backend"
  for_each = local.apim.api_management_ai_backend

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags ? coalesce(local.global_settings.tags, {}) : {}

  remote_objects = {
    api_management              = local.combined_objects_api_management
    resource_groups             = local.combined_objects_resource_groups
    managed_identities          = local.combined_objects_managed_identities
    ai_services                 = local.combined_objects_ai_services
    cognitive_services_accounts = local.combined_objects_cognitive_services_accounts
    cognitive_deployment        = local.combined_objects_cognitive_deployment
    cognitive_account_project   = local.combined_objects_cognitive_account_projects
  }
}
output "api_management_ai_backend" {
  description = "Business-keyed APIM AI backend modules created by the root configuration."
  value       = module.api_management_ai_backend
}

module "api_management_backend_pool" {
  source   = "./modules/apim/api_management_backend_pool"
  for_each = local.apim.api_management_backend_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags ? coalesce(local.global_settings.tags, {}) : {}

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
    ai_backends     = local.combined_objects_api_management_ai_backend
    backends        = local.combined_objects_api_management_backend
  }
}
output "api_management_backend_pool" {
  description = "Business-keyed APIM backend pool modules created by the root configuration."
  value       = module.api_management_backend_pool
}

module "api_management_api_policy" {
  source   = "./modules/apim/api_management_api_policy"
  for_each = local.apim.api_management_api_policy

  depends_on = [
    module.api_management_ai_backend,
    module.api_management_backend_pool,
    module.api_management_named_value,
    module.api_management_policy_fragment
  ]

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_name            = try(each.value.api.name, null) != null ? each.value.api.name : local.combined_objects_api_management_api[coalesce(try(each.value.api.lz_key, null), local.client_config.landingzone_key)][each.value.api.key].name
  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_api_policy" {
  value = module.api_management_api_policy
}

module "api_management_api_operation_tag" {
  source   = "./modules/apim/api_management_api_operation_tag"
  for_each = local.apim.api_management_api_operation_tag

  api_operation_id = try(each.value.api_operation.id, null) != null ? each.value.api_operation.id : local.combined_objects_api_management_api_operation[coalesce(try(each.value.api_operation.lz_key, null), local.client_config.landingzone_key)][each.value.api_operation.key].id

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value


  remote_objects = {
  }
}
output "api_management_api_operation_tag" {
  value = module.api_management_api_operation_tag
}
module "api_management_api_operation_policy" {
  source   = "./modules/apim/api_management_api_operation_policy"
  for_each = local.apim.api_management_api_operation_policy

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_name            = try(each.value.api.name, null) != null ? each.value.api.name : local.combined_objects_api_management_api[coalesce(try(each.value.api.lz_key, null), local.client_config.landingzone_key)][each.value.api.key].name
  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management               = local.combined_objects_api_management
    resource_group               = local.combined_objects_resource_groups
    api_management_api_operation = local.combined_objects_api_management_api_operation
  }
}
output "api_management_api_operation_policy" {
  value = module.api_management_api_operation_policy
}

module "api_management_certificate" {
  source   = "./modules/apim/api_management_certificate"
  for_each = local.apim.api_management_certificate

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management                = local.combined_objects_api_management
    resource_group                = local.combined_objects_resource_groups
    keyvault_certificates         = local.combined_objects_keyvault_certificates
    keyvault_certificate_requests = local.combined_objects_keyvault_certificate_requests
    managed_identities            = local.combined_objects_managed_identities
  }
}
output "api_management_certificate" {
  value = module.api_management_certificate
}

module "api_management_custom_domain" {
  source     = "./modules/apim/api_management_custom_domain"
  for_each   = local.apim.api_management_custom_domain
  depends_on = [module.keyvault_access_policies]

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_id = try(each.value.api_management.id, null) != null ? each.value.api_management.id : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].id

  remote_objects = {
    api_management                = local.combined_objects_api_management
    keyvault_certificates         = local.combined_objects_keyvault_certificates
    keyvault_certificate_requests = local.combined_objects_keyvault_certificate_requests
    managed_identities            = local.combined_objects_managed_identities
  }
}
output "api_management_custom_domain" {
  value     = module.api_management_custom_domain
  sensitive = true
}

module "api_management_diagnostic" {
  source   = "./modules/apim/api_management_diagnostic"
  for_each = local.apim.api_management_diagnostic

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null ? each.value.resource_group.name : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name
  api_management_logger_id = try(coalesce(
    try(each.value.api_management_logger.id, null),
    try(local.combined_objects_api_management_logger[coalesce(try(each.value.api_management_logger.lz_key, null), local.client_config.landingzone_key)][each.value.api_management_logger.key].id, null),
    each.value.identifier == "azuremonitor" ? format(
      "%s/loggers/azuremonitor",
      coalesce(
        try(each.value.api_management.id, null),
        try(local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].id, null),
        format(
          "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ApiManagement/service/%s",
          local.client_config.subscription_id,
          try(each.value.resource_group.name, null) != null ? each.value.resource_group.name : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name,
          try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
        )
      )
    ) : null
  ), null)

  remote_objects = {
    api_management        = local.combined_objects_api_management
    resource_group        = local.combined_objects_resource_groups
    api_management_logger = local.combined_objects_api_management_logger
  }
}

output "api_management_diagnostic" {
  value = module.api_management_diagnostic
}

module "api_management_user" {
  source   = "./modules/apim/api_management_user"
  for_each = local.apim.api_management_user

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_user" {
  value = module.api_management_user
}

module "api_management_gateway" {
  source   = "./modules/apim/api_management_gateway"
  for_each = local.apim.api_management_gateway

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_gateway" {
  value = module.api_management_gateway
}

module "api_management_gateway_api" {
  source   = "./modules/apim/api_management_gateway_api"
  for_each = local.apim.api_management_gateway_api

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management_api     = local.combined_objects_api_management_api
    api_management         = local.combined_objects_api_management
    resource_group         = local.combined_objects_resource_groups
    api_management_gateway = local.combined_objects_api_management_gateway
  }
}
output "api_management_gateway_api" {
  value = module.api_management_gateway_api
}

module "api_management_group" {
  source   = "./modules/apim/api_management_group"
  for_each = local.apim.api_management_group

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_group" {
  value = module.api_management_group
}

module "api_management_subscription" {
  source   = "./modules/apim/api_management_subscription"
  for_each = local.apim.api_management_subscription

  depends_on = [module.api_management_product]

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name
  product_id          = try(each.value.product.product_id, null) != null || try(each.value.product.key, null) == null ? try(each.value.product.product_id, null) : local.combined_objects_api_management_product[coalesce(try(each.value.product.lz_key, null), local.client_config.landingzone_key)][each.value.product.key].id

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_subscription" {
  value     = module.api_management_subscription
  sensitive = true
}

module "api_management_product" {
  source   = "./modules/apim/api_management_product"
  for_each = local.apim.api_management_product

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  api_management_name = try(each.value.api_management.name, null) != null ? each.value.api_management.name : local.combined_objects_api_management[coalesce(try(each.value.api_management.lz_key, null), local.client_config.landingzone_key)][each.value.api_management.key].name
  resource_group_name = try(each.value.resource_group.name, null) != null || try(each.value.resource_group_name, null) != null ? coalesce(try(each.value.resource_group.name, null), try(each.value.resource_group_name, null)) : local.combined_objects_resource_groups[coalesce(try(each.value.resource_group.lz_key, null), local.client_config.landingzone_key)][coalesce(try(each.value.resource_group_key, null), try(each.value.resource_group.key, null))].name

  remote_objects = {
    api_management = local.combined_objects_api_management
    resource_group = local.combined_objects_resource_groups
  }
}
output "api_management_product" {
  value = module.api_management_product
}

module "api_management_named_value" {
  source   = "./modules/apim/api_management_named_value"
  for_each = local.apim.api_management_named_value

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management     = local.combined_objects_api_management
    resource_groups    = local.combined_objects_resource_groups
    keyvaults          = local.combined_objects_keyvaults
    managed_identities = local.combined_objects_managed_identities
  }
}
output "api_management_named_value" {
  value = module.api_management_named_value
}

module "api_management_api_release" {
  source   = "./modules/apim/api_management_api_release"
  for_each = local.apim.api_management_api_release

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management_api = local.combined_objects_api_management_api
  }
}
output "api_management_api_release" {
  value = module.api_management_api_release
}

module "api_management_api_schema" {
  source   = "./modules/apim/api_management_api_schema"
  for_each = local.apim.api_management_api_schema

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management_api = local.combined_objects_api_management_api
    api_management     = local.combined_objects_api_management
    resource_groups    = local.combined_objects_resource_groups
  }
}
output "api_management_api_schema" {
  value = module.api_management_api_schema
}

module "api_management_api_tag" {
  source   = "./modules/apim/api_management_api_tag"
  for_each = local.apim.api_management_api_tag

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management_api = local.combined_objects_api_management_api
    api_management_tag = local.combined_objects_api_management_tag
  }
}
output "api_management_api_tag" {
  value = module.api_management_api_tag
}

module "api_management_api_tag_description" {
  source   = "./modules/apim/api_management_api_tag_description"
  for_each = local.apim.api_management_api_tag_description

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management_api_tag = local.combined_objects_api_management_api_tag
  }
}
output "api_management_api_tag_description" {
  value = module.api_management_api_tag_description
}

module "api_management_api_version_set" {
  source   = "./modules/apim/api_management_api_version_set"
  for_each = local.apim.api_management_api_version_set

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_api_version_set" {
  value = module.api_management_api_version_set
}

module "api_management_gateway_certificate_authority" {
  source   = "./modules/apim/api_management_gateway_certificate_authority"
  for_each = local.apim.api_management_gateway_certificate_authority

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management             = local.combined_objects_api_management
    api_management_gateway     = local.combined_objects_api_management_gateway
    api_management_certificate = local.combined_objects_api_management_certificate
  }
}
output "api_management_gateway_certificate_authority" {
  value = module.api_management_gateway_certificate_authority
}

module "api_management_gateway_host_name_configuration" {
  source   = "./modules/apim/api_management_gateway_host_name_configuration"
  for_each = local.apim.api_management_gateway_host_name_configuration

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management             = local.combined_objects_api_management
    api_management_gateway     = local.combined_objects_api_management_gateway
    api_management_certificate = local.combined_objects_api_management_certificate
  }
}
output "api_management_gateway_host_name_configuration" {
  value = module.api_management_gateway_host_name_configuration
}

module "api_management_global_schema" {
  source   = "./modules/apim/api_management_global_schema"
  for_each = local.apim.api_management_global_schema

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_global_schema" {
  value = module.api_management_global_schema
}

module "api_management_group_user" {
  source   = "./modules/apim/api_management_group_user"
  for_each = local.apim.api_management_group_user

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management       = local.combined_objects_api_management
    resource_groups      = local.combined_objects_resource_groups
    api_management_group = local.combined_objects_api_management_group
    api_management_user  = local.combined_objects_api_management_user
  }
}
output "api_management_group_user" {
  value = module.api_management_group_user
}

module "api_management_policy" {
  source   = "./modules/apim/api_management_policy"
  for_each = local.apim.api_management_policy

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management = local.combined_objects_api_management
  }
}
output "api_management_policy" {
  value = module.api_management_policy
}

module "api_management_policy_fragment" {
  source   = "./modules/apim/api_management_policy_fragment"
  for_each = local.apim.api_management_policy_fragment

  depends_on = [module.api_management_named_value]

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management = local.combined_objects_api_management
  }
}
output "api_management_policy_fragment" {
  value = module.api_management_policy_fragment
}

module "api_management_product_api" {
  source   = "./modules/apim/api_management_product_api"
  for_each = local.apim.api_management_product_api

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management_api     = local.combined_objects_api_management_api
    api_management         = local.combined_objects_api_management
    resource_groups        = local.combined_objects_resource_groups
    api_management_product = local.combined_objects_api_management_product
  }
}
output "api_management_product_api" {
  value = module.api_management_product_api
}

module "api_management_product_group" {
  source   = "./modules/apim/api_management_product_group"
  for_each = local.apim.api_management_product_group

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management         = local.combined_objects_api_management
    resource_groups        = local.combined_objects_resource_groups
    api_management_group   = local.combined_objects_api_management_group
    api_management_product = local.combined_objects_api_management_product
  }
}
output "api_management_product_group" {
  value = module.api_management_product_group
}

module "api_management_product_tag" {
  source   = "./modules/apim/api_management_product_tag"
  for_each = local.apim.api_management_product_tag

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management         = local.combined_objects_api_management
    resource_groups        = local.combined_objects_resource_groups
    api_management_product = local.combined_objects_api_management_product
    api_management_tag     = local.combined_objects_api_management_tag
  }
}
output "api_management_product_tag" {
  value = module.api_management_product_tag
}

module "api_management_redis_cache" {
  source   = "./modules/apim/api_management_redis_cache"
  for_each = local.apim.api_management_redis_cache

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management = local.combined_objects_api_management
    redis_caches   = local.combined_objects_redis_caches
  }
}
output "api_management_redis_cache" {
  value = module.api_management_redis_cache
}

module "api_management_standalone_gateway" {
  source   = "./modules/apim/api_management_standalone_gateway"
  for_each = local.apim.api_management_standalone_gateway

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    resource_groups = local.combined_objects_resource_groups
    vnets           = local.combined_objects_vnets
  }
}
output "api_management_standalone_gateway" {
  value = module.api_management_standalone_gateway
}

module "api_management_tag" {
  source   = "./modules/apim/api_management_tag"
  for_each = local.apim.api_management_tag

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags

  remote_objects = {
    api_management = local.combined_objects_api_management
  }
}
output "api_management_tag" {
  value = module.api_management_tag
}

module "api_management_authorization_server" {
  source   = "./modules/apim/api_management_authorization_server"
  for_each = local.apim.api_management_authorization_server

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_authorization_server" {
  value = module.api_management_authorization_server
}

module "api_management_email_template" {
  source   = "./modules/apim/api_management_email_template"
  for_each = local.apim.api_management_email_template

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_email_template" {
  value = module.api_management_email_template
}

module "api_management_identity_provider_aad" {
  source   = "./modules/apim/api_management_identity_provider_aad"
  for_each = local.apim.api_management_identity_provider_aad

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_identity_provider_aad" {
  value = module.api_management_identity_provider_aad
}

module "api_management_identity_provider_aadb2c" {
  source   = "./modules/apim/api_management_identity_provider_aadb2c"
  for_each = local.apim.api_management_identity_provider_aadb2c

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_identity_provider_aadb2c" {
  value = module.api_management_identity_provider_aadb2c
}

module "api_management_identity_provider_facebook" {
  source   = "./modules/apim/api_management_identity_provider_facebook"
  for_each = local.apim.api_management_identity_provider_facebook

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_identity_provider_facebook" {
  value = module.api_management_identity_provider_facebook
}

module "api_management_identity_provider_google" {
  source   = "./modules/apim/api_management_identity_provider_google"
  for_each = local.apim.api_management_identity_provider_google

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_identity_provider_google" {
  value = module.api_management_identity_provider_google
}

module "api_management_identity_provider_microsoft" {
  source   = "./modules/apim/api_management_identity_provider_microsoft"
  for_each = local.apim.api_management_identity_provider_microsoft

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_identity_provider_microsoft" {
  value = module.api_management_identity_provider_microsoft
}

module "api_management_identity_provider_twitter" {
  source   = "./modules/apim/api_management_identity_provider_twitter"
  for_each = local.apim.api_management_identity_provider_twitter

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_identity_provider_twitter" {
  value = module.api_management_identity_provider_twitter
}

module "api_management_notification_recipient_email" {
  source   = "./modules/apim/api_management_notification_recipient_email"
  for_each = local.apim.api_management_notification_recipient_email

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management = local.combined_objects_api_management
  }
}
output "api_management_notification_recipient_email" {
  value = module.api_management_notification_recipient_email
}

module "api_management_notification_recipient_user" {
  source   = "./modules/apim/api_management_notification_recipient_user"
  for_each = local.apim.api_management_notification_recipient_user

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management       = local.combined_objects_api_management
    api_management_users = local.combined_objects_api_management_user
  }
}
output "api_management_notification_recipient_user" {
  value = module.api_management_notification_recipient_user
}

module "api_management_openid_connect_provider" {
  source   = "./modules/apim/api_management_openid_connect_provider"
  for_each = local.apim.api_management_openid_connect_provider

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management  = local.combined_objects_api_management
    resource_groups = local.combined_objects_resource_groups
  }
}
output "api_management_openid_connect_provider" {
  value = module.api_management_openid_connect_provider
}

module "api_management_workspace" {
  source   = "./modules/apim/api_management_workspace"
  for_each = local.apim.api_management_workspace

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management = local.combined_objects_api_management
  }
}
output "api_management_workspace" {
  value = module.api_management_workspace
}

module "api_management_workspace_api_version_set" {
  source   = "./modules/apim/api_management_workspace_api_version_set"
  for_each = local.apim.api_management_workspace_api_version_set

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management_workspace = local.combined_objects_api_management_workspace
  }
}
output "api_management_workspace_api_version_set" {
  value = module.api_management_workspace_api_version_set
}

module "api_management_workspace_certificate" {
  source   = "./modules/apim/api_management_workspace_certificate"
  for_each = local.apim.api_management_workspace_certificate

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management_workspace      = local.combined_objects_api_management_workspace
    keyvault_certificate_requests = local.combined_objects_keyvault_certificate_requests
    keyvault_certificates         = local.combined_objects_keyvault_certificates
    keyvaults                     = local.combined_objects_keyvaults
    managed_identities            = local.combined_objects_managed_identities
  }
}
output "api_management_workspace_certificate" {
  value = module.api_management_workspace_certificate
}

module "api_management_workspace_named_value" {
  source   = "./modules/apim/api_management_workspace_named_value"
  for_each = local.apim.api_management_workspace_named_value

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management_workspace = local.combined_objects_api_management_workspace
    keyvaults                = local.combined_objects_keyvaults
    managed_identities       = local.combined_objects_managed_identities
  }
}
output "api_management_workspace_named_value" {
  value = module.api_management_workspace_named_value
}

module "api_management_workspace_policy" {
  source   = "./modules/apim/api_management_workspace_policy"
  for_each = local.apim.api_management_workspace_policy

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management_workspace = local.combined_objects_api_management_workspace
  }
}
output "api_management_workspace_policy" {
  value = module.api_management_workspace_policy
}

module "api_management_workspace_policy_fragment" {
  source   = "./modules/apim/api_management_workspace_policy_fragment"
  for_each = local.apim.api_management_workspace_policy_fragment

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management_workspace = local.combined_objects_api_management_workspace
  }
}
output "api_management_workspace_policy_fragment" {
  value = module.api_management_workspace_policy_fragment
}

module "api_management_product_policy" {
  source   = "./modules/apim/api_management_product_policy"
  for_each = local.apim.api_management_product_policy

  depends_on = [
    module.api_management_product,
    module.api_management_policy_fragment
  ]

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    api_management         = local.combined_objects_api_management
    resource_groups        = local.combined_objects_resource_groups
    api_management_product = local.combined_objects_api_management_product
  }
}
output "api_management_product_policy" {
  value = module.api_management_product_policy
}
