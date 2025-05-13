locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  # Tags for the main NGFW resource
  tags = var.base_tags ? merge(
    try(var.global_settings.tags, {}),
    try(var.resource_group.tags, {}),
    local.module_tag,
    try(var.settings.tags, {})
    ) : merge(
    local.module_tag,
    try(var.settings.tags, {})
  )

  # Location for the NGFW resource
  location = coalesce(var.location, var.resource_group.location)

  # Resource group name for the NGFW resource
  resource_group_name = var.resource_group.name

  # Settings for the local_rulestack sub-module
  # Ensure that the sub-module also receives necessary context like client_config, global_settings, base_tags, remote_objects
  local_rulestack_module_settings = merge(
    var.settings.local_rulestack,
    {
      # Pass down location and resource_group_name if the sub-module needs them explicitly,
      # or it can derive them from its own var.resource_group and var.location if structured that way.
      # For now, assume sub-module's variables.tf will define how it gets these.
      # If sub-module's `location` is null, it should default to this main module's location.
      location = try(var.settings.local_rulestack.location, local.location)
    }
  )
}
