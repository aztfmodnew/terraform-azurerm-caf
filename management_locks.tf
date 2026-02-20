module "management_locks" {
  source   = "./modules/management_lock"
  for_each = local.shared_services.management_locks

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
}

output "management_locks" {
  value = module.management_locks
}
