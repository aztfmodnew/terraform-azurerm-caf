module "pim_active_role_assignments" {
  source   = "./modules/authorization/pim_active_role_assignments"
  for_each = local.pim.pim_active_role_assignments

  settings        = each.value
  global_settings = local.global_settings
  client_config   = local.client_config

  remote_objects = {
    managed_identities = local.combined_objects_managed_identities
    management_groups  = local.combined_objects_management_groups
    role_definitions   = local.combined_objects_role_definitions
    subscriptions      = local.combined_objects_subscriptions
    azuread_groups     = local.combined_objects_azuread_groups
  }
}

module "pim_eligible_role_assignments" {
  source   = "./modules/authorization/pim_eligible_role_assignments"
  for_each = local.pim.pim_eligible_role_assignments

  settings        = each.value
  global_settings = local.global_settings
  client_config   = local.client_config

  remote_objects = {
    managed_identities = local.combined_objects_managed_identities
    management_groups  = local.combined_objects_management_groups
    role_definitions   = local.combined_objects_role_definitions
    subscriptions      = local.combined_objects_subscriptions
    azuread_groups     = local.combined_objects_azuread_groups
  }
}

output "pim_active_role_assignments" {
  value = module.pim_active_role_assignments
}

output "pim_eligible_role_assignments" {
  value = module.pim_eligible_role_assignments
}
