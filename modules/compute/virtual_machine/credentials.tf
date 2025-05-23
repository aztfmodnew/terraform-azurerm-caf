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
  count = try(var.settings.virtual_machine_settings[local.os_type].admin_password_key, null) == null && (try(var.settings.virtual_machine_settings["linux"].disable_password_authentication, false) == true || try(var.settings.virtual_machine_settings["legacy"].os_profile_linux_config.disable_password_authentication, false) == true) ? 1 : 0

  length           = 123
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

resource "azurerm_key_vault_secret" "admin_password" {
  count = try(var.settings.virtual_machine_settings[local.os_type].admin_password_key, null) == null && (try(var.settings.virtual_machine_settings["linux"].disable_password_authentication, false) == true || try(var.settings.virtual_machine_settings["legacy"].os_profile_linux_config.disable_password_authentication, false) == true) ? 1 : 0

  name         = format("%s-admin-password", var.settings.virtual_machine_settings[local.os_type].name)
  value        = random_password.admin[0].result
  key_vault_id = local.keyvault.id

  lifecycle {
    ignore_changes = [
      name, value, key_vault_id
    ]
  }
}
