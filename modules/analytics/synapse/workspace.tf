# naming convention
resource "azurecaf_name" "ws" {
  name          = var.settings.name
  resource_type = "azurerm_synapse_workspace"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace
# Tested with : AzureRM 2.57.0
resource "azurerm_synapse_workspace" "ws" {
  name                                 = azurecaf_name.ws.result
  resource_group_name                  = local.resource_group_name
  location                             = local.location
  storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
  sql_administrator_login              = try(var.settings.sql_administrator_login, null)
  sql_administrator_login_password = try(coalesce(
    try(var.settings.sql_administrator_login_password, null),
    random_password.sql_admin[0].result
  ), null)
  azuread_authentication_only          = coalesce(try(var.settings.azuread_authentication_only, null), false)
  compute_subnet_id                    = local.compute_subnet_id
  managed_virtual_network_enabled      = coalesce(try(var.settings.managed_virtual_network_enabled, null), true)
  sql_identity_control_enabled         = try(var.settings.sql_identity_control_enabled, null)
  managed_resource_group_name          = try(var.settings.managed_resource_group_name, null)
  data_exfiltration_protection_enabled = try(var.settings.data_exfiltration_protection_enabled, null)
  linking_allowed_for_aad_tenant_ids   = try(var.settings.linking_allowed_for_aad_tenant_ids, null)
  public_network_access_enabled        = coalesce(try(var.settings.public_network_access_enabled, null), true)
  purview_id                           = try(var.settings.purview_id, null)
  tags                                 = local.tags

  identity {
    type = coalesce(try(var.settings.identity.type, null), "SystemAssigned")
    identity_ids = contains(
      ["UserAssigned", "SystemAssigned, UserAssigned"],
      coalesce(try(var.settings.identity.type, null), "SystemAssigned")
      ) ? (
      length(coalesce(try(var.settings.identity.identity_ids, null), [])) > 0
      ? var.settings.identity.identity_ids
      : local.managed_identities
    ) : null
  }



  dynamic "azure_devops_repo" {
    for_each = try(var.settings.azure_devops_repo, null) != null ? [var.settings.azure_devops_repo] : []

    content {
      account_name    = try(azure_devops_repo.value.account_name, null)
      branch_name     = try(azure_devops_repo.value.branch_name, null)
      last_commit_id  = try(azure_devops_repo.value.last_commit_id, null)
      project_name    = try(azure_devops_repo.value.project_name, null)
      repository_name = try(azure_devops_repo.value.repository_name, null)
      root_folder     = try(azure_devops_repo.value.root_folder, null)
      tenant_id       = try(azure_devops_repo.value.tenant_id, null)
    }
  }

  dynamic "customer_managed_key" {
    for_each = try(coalesce(
      try(var.settings.customer_managed_key_versionless_id, null),
      try(var.settings.customer_managed_key.key_versionless_id, null)
    ), null) == null ? [] : [1]

    content {
      key_versionless_id = coalesce(
        try(var.settings.customer_managed_key_versionless_id, null),
        try(var.settings.customer_managed_key.key_versionless_id, null)
      )
      key_name = coalesce(
        try(var.settings.customer_managed_key_key_name, null),
        try(var.settings.customer_managed_key.key_name, null),
        "cmk"
      )
      user_assigned_identity_id = try(coalesce(
        try(var.settings.customer_managed_key_user_assigned_identity_id, null),
        try(var.settings.customer_managed_key.user_assigned_identity_id, null)
      ), null)
    }
  }

  dynamic "github_repo" {
    for_each = try(var.settings.github_repo, null) != null ? [var.settings.github_repo] : []

    content {
      account_name    = try(github_repo.value.account_name, null)
      branch_name     = try(github_repo.value.branch_name, null)
      last_commit_id  = try(github_repo.value.last_commit_id, null)
      repository_name = try(github_repo.value.repository_name, null)
      root_folder     = try(github_repo.value.root_folder, null)
      git_url         = try(github_repo.value.git_url, null)
    }
  }

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

# Generate sql server random admin password if not provided in the attribute administrator_login_password
resource "random_password" "sql_admin" {
  count = try(var.settings.sql_administrator_login, null) != null && try(var.settings.sql_administrator_login_password, null) == null ? 1 : 0

  length           = 128
  special          = true
  upper            = true
  numeric          = true
  override_special = "$#%"
}

# Store the generated password into keyvault for password rotation support
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count = try(var.settings.sql_administrator_login, null) != null && try(var.settings.sql_administrator_login_password, null) == null ? 1 : 0

  name            = format("%s-synapse-sql-admin-password", azurerm_synapse_workspace.ws.name)
  value           = random_password.sql_admin[0].result
  key_vault_id    = var.keyvault_id
  not_before_date = try(var.settings.sql_administrator_login_password_not_before, null)
  content_type    = "text/plain"
  expiration_date = coalesce(try(var.settings.sql_administrator_login_password_expiration_date, null), timeadd(timestamp(), "2160h")) # 2160 hours = 90 days
  tags            = try(var.settings.key_vault_secret_tags, null)
  # This is to prevent the secret from being updated when the password is changed
  # in the azurerm_synapse_workspace resource. This is a workaround for the issue
  # where the azurerm_synapse_workspace resource does not support updating the password
  # without recreating the resource.

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  dynamic "timeouts" {
    for_each = try(var.settings.key_vault_secret_timeouts, null) == null ? [] : [var.settings.key_vault_secret_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_key_vault_secret" "sql_admin" {
  count = try(var.settings.sql_administrator_login, null) != null && try(var.settings.sql_administrator_login_password, null) == null ? 1 : 0

  name            = format("%s-synapse-sql-admin-username", azurerm_synapse_workspace.ws.name)
  value           = var.settings.sql_administrator_login
  key_vault_id    = var.keyvault_id
  content_type    = "text/plain"
  expiration_date = coalesce(try(var.settings.sql_administrator_login_password_expiration_date, null), timeadd(timestamp(), "2160h")) # 2160 hours = 90 days
  tags            = try(var.settings.key_vault_secret_tags, null)

  dynamic "timeouts" {
    for_each = try(var.settings.key_vault_secret_timeouts, null) == null ? [] : [var.settings.key_vault_secret_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_key_vault_secret" "synapse_name" {
  count = try(var.settings.sql_administrator_login, null) != null && try(var.settings.sql_administrator_login_password, null) == null ? 1 : 0

  name            = format("%s-synapse-name", azurerm_synapse_workspace.ws.name)
  value           = azurerm_synapse_workspace.ws.name
  key_vault_id    = var.keyvault_id
  content_type    = "text/plain"
  expiration_date = coalesce(try(var.settings.sql_administrator_login_password_expiration_date, null), timeadd(timestamp(), "2160h")) # 2160 hours = 90 days
  tags            = try(var.settings.key_vault_secret_tags, null)

  dynamic "timeouts" {
    for_each = try(var.settings.key_vault_secret_timeouts, null) == null ? [] : [var.settings.key_vault_secret_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_key_vault_secret" "synapse_rg_name" {
  count = try(var.settings.sql_administrator_login, null) != null && try(var.settings.sql_administrator_login_password, null) == null ? 1 : 0

  name            = format("%s-synapse-resource-group-name", azurerm_synapse_workspace.ws.name)
  value           = local.resource_group_name
  key_vault_id    = var.keyvault_id
  content_type    = "text/plain"
  expiration_date = coalesce(try(var.settings.sql_administrator_login_password_expiration_date, null), timeadd(timestamp(), "2160h")) # 2160 hours = 90 days
  tags            = try(var.settings.key_vault_secret_tags, null)

  dynamic "timeouts" {
    for_each = try(var.settings.key_vault_secret_timeouts, null) == null ? [] : [var.settings.key_vault_secret_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

# for backwards compatibility to create single firewall rule
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule
# Tested with : AzureRm 2.57.0
resource "azurerm_synapse_firewall_rule" "wrkspc_firewall" {
  count = try(var.settings.workspace_firewall, null) == null ? 0 : 1

  name                 = var.settings.workspace_firewall.name
  synapse_workspace_id = azurerm_synapse_workspace.ws.id
  start_ip_address     = var.settings.workspace_firewall.start_ip
  end_ip_address       = var.settings.workspace_firewall.end_ip

  dynamic "timeouts" {
    for_each = try(var.settings.workspace_firewall.timeouts, null) == null ? [] : [var.settings.workspace_firewall.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

# supports adding multiple synapse firewall rules
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule
# Tested with : AzureRm 2.57.0
resource "azurerm_synapse_firewall_rule" "wrkspc_firewalls" {
  for_each = try(var.settings.workspace_firewalls, {})

  # use key as firewall name if name attribute not defined
  name                 = coalesce(try(each.value.name, null), each.key)
  synapse_workspace_id = azurerm_synapse_workspace.ws.id
  # start_ip and end_ip must be specified in each individual workspace_firewall_rule
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_synapse_workspace_aad_admin" "wrkspc_aad_admin" {
  for_each             = try(var.settings.aad_admin, null) != null ? { for k, v in [var.settings.aad_admin] : k => v } : {}
  synapse_workspace_id = azurerm_synapse_workspace.ws.id
  login                = try(each.value.login, null)
  object_id            = try(each.value.object_id, null)
  tenant_id            = try(each.value.tenant_id, null)

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}