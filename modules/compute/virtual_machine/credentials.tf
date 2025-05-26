#
# Get the admin username and password from keyvault
#

locals {
  admin_username = can(var.settings.virtual_machine_settings[local.os_type].admin_username_key) ? data.azurerm_key_vault_secret.admin_username.0.value : null
  admin_password = can(var.settings.virtual_machine_settings[local.os_type].admin_password_key) ? data.azurerm_key_vault_secret.admin_password.0.value : null
}

data "azurerm_key_vault_secret" "admin_username" {
  count = try(var.settings.virtual_machine_settings[local.os_type].admin_username_key, null) == null ? 0 : 1

  name         = var.settings.virtual_machine_settings[local.os_type].admin_username_key
  key_vault_id = local.keyvault.id
}

data "azurerm_key_vault_secret" "admin_password" {
  count = try(var.settings.virtual_machine_settings[local.os_type].admin_password_key, null) == null ? 0 : 1

  name         = var.settings.virtual_machine_settings[local.os_type].admin_password_key
  key_vault_id = local.keyvault.id
}

resource "random_password" "admin" {
  for_each = try(var.settings.virtual_machine_settings[local.os_type].admin_password_key, null) == null && (local.os_type == "windows" || try(var.settings.virtual_machine_settings["linux"].disable_password_authentication, true) == false || try(var.settings.virtual_machine_settings["legacy"].os_profile_linux_config.disable_password_authentication, true) == false) ? var.settings.virtual_machine_settings : {}

  length           = 123
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

resource "azurerm_key_vault_secret" "admin_password" {
  for_each = try(var.settings.virtual_machine_settings[local.os_type].admin_password_key, null) == null && (local.os_type == "windows" || try(var.settings.virtual_machine_settings["linux"].disable_password_authentication, true) == false || try(var.settings.virtual_machine_settings["legacy"].os_profile_linux_config.disable_password_authentication, true) == false) ? var.settings.virtual_machine_settings : {}

  name         = format("%s-admin-password", try(data.azurecaf_name.windows_computer_name[each.key].result, data.azurecaf_name.linux_computer_name[each.key].result, azurecaf_name.legacy_computer_name[each.key].result))
  value        = random_password.admin[local.os_type].result
  key_vault_id = local.keyvault.id

  lifecycle {
    ignore_changes = [
      name, value, key_vault_id
    ]
  }
}
