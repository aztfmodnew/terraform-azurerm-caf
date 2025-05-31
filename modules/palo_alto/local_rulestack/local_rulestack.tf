resource "azurerm_palo_alto_local_rulestack" "local_rulestack" {
  name                = var.settings.name
  resource_group_name = local.resource_group_name
  location            = local.location

  description           = try(var.settings.description, null)
  anti_spyware_profile  = try(var.settings.anti_spyware_profile, null)
  anti_virus_profile    = try(var.settings.anti_virus_profile, null)
  dns_subscription      = try(var.settings.dns_subscription_enabled, null)
  file_blocking_profile = try(var.settings.file_blocking_profile, null)
  url_filtering_profile = try(var.settings.url_filtering_profile, null)
  vulnerability_profile = try(var.settings.vulnerability_profile, null)
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

}
