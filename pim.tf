module "pim_active_role_assignments" {
  source   = "./modules/authorization/pim_active_role_assignments"
  for_each = local.pim.pim_active_role_assignments

  settings        = each.value
  global_settings = local.global_settings
  client_config   = local.client_config
  remote_objects  = {}
}

output "pim_active_role_assignments" {
  value = module.pim_active_role_assignments
}

module "pim_eligible_role_assignments" {
  source   = "./modules/authorization/pim_eligible_role_assignments"
  for_each = local.pim.pim_eligible_role_assignments

  settings        = each.value
  global_settings = local.global_settings
  client_config   = local.client_config
  remote_objects  = {}
}

output "pim_eligible_role_assignments" {
  value = module.pim_eligible_role_assignments
}
