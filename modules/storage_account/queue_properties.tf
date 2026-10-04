resource "azurerm_storage_account_queue_properties" "stg" {
  for_each = try(var.storage_account.queue_properties, null) == null ? {} : { queue_properties = var.storage_account.queue_properties }

  storage_account_id = azurerm_storage_account.stg.id

  dynamic "cors_rule" {
    for_each = try(var.storage_account.queue_properties.cors_rule, null) == null ? [] : [var.storage_account.queue_properties.cors_rule]

    content {
      allowed_headers    = cors_rule.value.allowed_headers
      allowed_methods    = cors_rule.value.allowed_methods
      allowed_origins    = cors_rule.value.allowed_origins
      exposed_headers    = cors_rule.value.exposed_headers
      max_age_in_seconds = cors_rule.value.max_age_in_seconds
    }
  }

  dynamic "logging" {
    for_each = try(var.storage_account.queue_properties.logging, null) == null ? [] : [var.storage_account.queue_properties.logging]

    content {
      delete                = logging.value.delete
      read                  = logging.value.read
      write                 = logging.value.write
      version               = logging.value.version
      retention_policy_days = try(logging.value.retention_policy_days, 7)
    }
  }

  dynamic "minute_metrics" {
    for_each = try(var.storage_account.queue_properties.minute_metrics, null) == null ? [] : try(var.storage_account.queue_properties.minute_metrics.enabled, true) ? [var.storage_account.queue_properties.minute_metrics] : []

    content {
      version               = minute_metrics.value.version
      include_apis          = try(minute_metrics.value.include_apis, null)
      retention_policy_days = try(minute_metrics.value.retention_policy_days, 7)
    }
  }

  dynamic "hour_metrics" {
    for_each = try(var.storage_account.queue_properties.hour_metrics, null) == null ? [] : try(var.storage_account.queue_properties.hour_metrics.enabled, true) ? [var.storage_account.queue_properties.hour_metrics] : []

    content {
      version               = hour_metrics.value.version
      include_apis          = try(hour_metrics.value.include_apis, null)
      retention_policy_days = try(hour_metrics.value.retention_policy_days, 7)
    }
  }

  timeouts {
    create = try(var.storage_account.queue_properties.timeouts.create, "30m")
    read   = try(var.storage_account.queue_properties.timeouts.read, "5m")
    update = try(var.storage_account.queue_properties.timeouts.update, "30m")
    delete = try(var.storage_account.queue_properties.timeouts.delete, "30m")
  }

  lifecycle {
    precondition {
      condition = anytrue([
        try(var.storage_account.queue_properties.cors_rule, null) != null,
        try(var.storage_account.queue_properties.logging, null) != null,
        try(var.storage_account.queue_properties.minute_metrics, null) != null && try(var.storage_account.queue_properties.minute_metrics.enabled, true),
        try(var.storage_account.queue_properties.hour_metrics, null) != null && try(var.storage_account.queue_properties.hour_metrics.enabled, true)
      ])
      error_message = "queue_properties requires at least one of cors_rule, logging, minute_metrics, or hour_metrics."
    }
  }
}
