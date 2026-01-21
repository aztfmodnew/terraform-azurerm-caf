module "chaos_studio_capabilities" {
  source   = "./modules/chaos_studio/chaos_studio_capability"
  for_each = local.chaos_studio.chaos_studio_capabilities

  depends_on = [
    module.chaos_studio_targets
  ]

  client_config   = local.client_config
  global_settings = local.global_settings
  base_tags       = local.global_settings.inherit_tags
  settings = merge(
    each.value,
    # Resolve chaos_studio_target_id from local modules if needed
    (
      try(each.value.chaos_studio_target_id, null) == null &&
      try(each.value.chaos_studio_target.key, null) != null
      ? {
        chaos_studio_target_id = try(module.chaos_studio_targets[try(each.value.chaos_studio_target.key, each.value.chaos_studio_target_key)].id, null)
      }
      : {}
    )
  )

  remote_objects = {
    chaos_studio_targets = local.combined_objects_chaos_studio_targets
  }
}

output "chaos_studio_capabilities" {
  value = module.chaos_studio_capabilities
}
