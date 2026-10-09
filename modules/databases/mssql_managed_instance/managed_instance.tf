resource "azurecaf_name" "mssqlmi" {

  name          = var.settings.name
  resource_type = "azurerm_mssql_server" //TODO: add support for sql mi
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
}

resource "azurerm_resource_group_template_deployment" "mssqlmi" {

  name                = azurecaf_name.mssqlmi.result
  resource_group_name = var.resource_group_name

  template_content = file(local.arm_filename)

  parameters_content = jsonencode(local.parameters_body)

  deployment_mode = "Incremental"

  timeouts {
    create = "10h"
    update = "10h"
    delete = "10h"
    read   = "5m"
  }
}

# Generate sql server random admin password if not provided in the attribute administrator_login_password
resource "random_password" "sqlmi_admin" {
  count = try(var.settings.administratorLoginPassword, null) == null ? 1 : 0

  length           = 128
  special          = true
  upper            = true
  numeric          = true
  override_special = "$#%"
}

# Both (azapi_resource.azapi_resource) have to be kept to support transition to azapi. Will be removed in next release
# Store the generated password into keyvault
resource "azurerm_key_vault_secret" "sqlmi_admin_password" {
  count = 0

  name         = format("%s-password", azurecaf_name.mssqlmi.result)
  value        = random_password.sqlmi_admin.0.result
  key_vault_id = var.keyvault.id

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# to support keyvault in a different subscription
resource "azapi_resource" "sqlmi_admin_password" {
  count = try(var.settings.administratorLoginPassword, null) == null ? 1 : 0

  type                 = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  name                 = format("%s-password-v1", azurecaf_name.mssqlmi.result)
  parent_id            = var.keyvault.id
  ignore_null_property = true
  tags                 = try(var.settings.administrator_password_secret.tags, null)

  body = {
    properties = {
      attributes = {
        enabled = try(var.settings.administrator_password_secret.enabled, true)
        exp     = try(var.settings.administrator_password_secret.expiration_date, null)
        nbf     = try(var.settings.administrator_password_secret.not_before_date, null)
      }
      contentType = try(var.settings.administrator_password_secret.content_type, null)
      value       = random_password.sqlmi_admin.0.result
    }
  }

  ignore_missing_property = true
  dynamic "timeouts" {
    for_each = try(var.settings.administrator_password_secret.timeouts, null) == null ? [] : [var.settings.administrator_password_secret.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

data "external" "sqlmi_admin_password" {
  count      = try(var.settings.administratorLoginPassword, null) == null ? 1 : 0
  depends_on = [azapi_resource.sqlmi_admin_password]
  program = [
    "bash", "-c",
    format(
      "az keyvault secret show -n '%s' --vault-name '%s' --query '{value: value }' -o json",
      format("%s-password-v1", azurecaf_name.mssqlmi.result),
      var.keyvault.name
    )
  ]
}

data "azapi_resource" "mssqlmi" {
  depends_on = [azurerm_resource_group_template_deployment.mssqlmi]

  name      = azurecaf_name.mssqlmi.result
  parent_id = local.parent_id
  type      = "Microsoft.Sql/managedInstances@2025-01-01"
  dynamic "timeouts" {
    for_each = try(var.settings.managed_instance_lookup_timeouts, null) == null ? [] : [var.settings.managed_instance_lookup_timeouts]
    content {
      read = try(timeouts.value.read, null)
    }
  }
}

locals {
  parent_id = format("/subscriptions/%s/resourceGroups/%s", var.client_config.subscription_id, var.resource_group_name)
  output = {
    id           = jsondecode(azurerm_resource_group_template_deployment.mssqlmi.output_content).id.value
    principal_id = jsondecode(azurerm_resource_group_template_deployment.mssqlmi.output_content).objectId.value
  }
}