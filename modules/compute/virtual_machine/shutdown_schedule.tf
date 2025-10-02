resource "azurerm_dev_test_global_vm_shutdown_schedule" "enabled" {
  count = can(var.settings.shutdown_schedule) ? 1 : 0

  virtual_machine_id = local.os_type == "linux" ? azurerm_linux_virtual_machine.vm["linux"].id : azurerm_windows_virtual_machine.vm["windows"].id
  location           = local.location
  enabled            = try(var.settings.shutdown_schedule.enabled, null)

  daily_recurrence_time = var.settings.shutdown_schedule.daily_recurrence_time
  timezone              = var.settings.shutdown_schedule.timezone

  notification_settings {
    enabled         = var.settings.shutdown_schedule.notification_settings.enabled
    time_in_minutes = try(var.settings.shutdown_schedule.notification_settings.time_in_minutes, "30")
    email           = try(var.settings.shutdown_schedule.notification_settings.email, null)
    webhook_url     = try(var.settings.shutdown_schedule.notification_settings.webhook_url, null)
  }

  tags = merge(local.tags, try(var.settings.shutdown_schedule.tags, {}))

  dynamic "timeouts" {
    for_each = try(var.settings.shutdown_schedule.timeouts, null) == null ? [] : [1]
    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }

  }

}
