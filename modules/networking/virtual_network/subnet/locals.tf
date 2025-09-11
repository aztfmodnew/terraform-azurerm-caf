locals {
  # Service Endpoint Policy IDs resolution
  # Supports both direct IDs and remote_objects references
  service_endpoint_policy_ids = var.service_endpoint_policy_ids != null ? var.service_endpoint_policy_ids : (
    try(var.settings.service_endpoint_policies, null) != null ? flatten([
      for policy_key in try(var.settings.service_endpoint_policies, []) : [
        coalesce(
          try(var.settings.service_endpoint_policy_ids[policy_key], null),
          try(var.remote_objects.subnet_service_endpoint_storage_policies[try(var.settings.service_endpoint_policy_lz_key, var.client_config.landingzone_key)][policy_key].id, null)
        )
      ]
    ]) : null
  )
}
