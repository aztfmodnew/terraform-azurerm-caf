# origin_group.tf
# azurerm_cdn_frontdoor_origin_group resource implementation

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                                                      = var.settings.name
  cdn_frontdoor_profile_id                                  = var.settings.cdn_frontdoor_profile_id
  session_affinity_enabled                                  = try(var.settings.session_affinity_enabled, true)
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = try(var.settings.restore_traffic_time_to_healed_or_new_endpoint_in_minutes, 10)

  load_balancing {
    additional_latency_in_milliseconds = try(var.settings.load_balancing.additional_latency_in_milliseconds, 50)
    sample_size                        = try(var.settings.load_balancing.sample_size, 4)
    successful_samples_required        = try(var.settings.load_balancing.successful_samples_required, 3)
  }

  dynamic "health_probe" {
    for_each = try(var.settings.health_probe, null) == null ? [] : [var.settings.health_probe]
    content {
      interval_in_seconds = health_probe.value.interval_in_seconds
      path                = try(health_probe.value.path, "/")
      protocol            = health_probe.value.protocol
      request_type        = try(health_probe.value.request_type, "HEAD")
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
