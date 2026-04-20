###############################################################################
# data_sources lookup resolution (name-based references)
#
# Purpose:
# - Keep legacy explicit-id data_sources untouched.
# - Resolve name-based entries through azurerm data sources.
# - Expose normalized local maps consumed by locals.combined_objects.tf
###############################################################################

locals {
  resource_groups_data_sources_name_lookup = {
    for key, value in try(var.data_sources.resource_groups, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null
  }

  subscriptions_data_sources_lookup = {
    for key, value in try(var.data_sources.subscriptions, {}) : key => value
    if try(value.id, null) == null && try(value.subscription_id, null) != null
  }

  azuread_groups_data_sources_static_lookup = {
    for key, value in try(var.data_sources.azuread_groups, {}) : key => value
    if coalesce(try(value.object_id, null), try(value.id, null), try(value.rbac_id, null)) != null
  }

  azuread_groups_data_sources_name_lookup = {
    for key, value in try(var.data_sources.azuread_groups, {}) : key => value
    if coalesce(try(value.object_id, null), try(value.id, null), try(value.rbac_id, null)) == null && try(value.display_name, null) != null
  }

  keyvaults_data_sources_name_lookup = {
    for key, value in try(var.data_sources.keyvaults, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  storage_accounts_data_sources_name_lookup = {
    for key, value in try(var.data_sources.storage_accounts, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  recovery_vaults_data_sources_name_lookup = {
    for key, value in try(var.data_sources.recovery_vaults, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  vnets_data_sources_name_lookup = {
    for key, value in try(var.data_sources.vnets, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  vnet_subnets_data_sources_name_lookup = merge([
    for vnet_key, vnet in local.vnets_data_sources_name_lookup : {
      for subnet_key, subnet in try(vnet.subnets, {}) : "${vnet_key}/${subnet_key}" => {
        vnet_key             = vnet_key
        subnet_key           = subnet_key
        subnet_name          = subnet.name
        resource_group_name  = try(subnet.resource_group_name, vnet.resource_group_name)
        virtual_network_name = vnet.name
      }
      if try(subnet.id, null) == null && try(subnet.name, null) != null
    }
  ]...)
}

data "azurerm_resource_group" "data_sources_lookup" {
  for_each = local.resource_groups_data_sources_name_lookup

  name = each.value.name
}

data "azurerm_subscription" "data_sources_lookup" {
  for_each = local.subscriptions_data_sources_lookup

  subscription_id = each.value.subscription_id
}

data "azuread_group" "data_sources_lookup" {
  for_each = local.azuread_groups_data_sources_name_lookup

  display_name = each.value.display_name
}

data "azurerm_key_vault" "data_sources_lookup" {
  for_each = local.keyvaults_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_storage_account" "data_sources_lookup" {
  for_each = local.storage_accounts_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_recovery_services_vault" "data_sources_lookup" {
  for_each = local.recovery_vaults_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_virtual_network" "data_sources_lookup" {
  for_each = local.vnets_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_subnet" "data_sources_lookup" {
  for_each = local.vnet_subnets_data_sources_name_lookup

  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
}

locals {
  resource_groups_data_sources_resolved = {
    for key, value in local.resource_groups_data_sources_name_lookup : key => merge(
      value,
      {
        id       = data.azurerm_resource_group.data_sources_lookup[key].id
        name     = data.azurerm_resource_group.data_sources_lookup[key].name
        location = data.azurerm_resource_group.data_sources_lookup[key].location
        tags     = try(data.azurerm_resource_group.data_sources_lookup[key].tags, null)
      }
    )
  }

  subscriptions_data_sources_resolved = {
    for key, value in local.subscriptions_data_sources_lookup : key => merge(
      value,
      {
        id              = data.azurerm_subscription.data_sources_lookup[key].id
        subscription_id = data.azurerm_subscription.data_sources_lookup[key].subscription_id
        display_name    = try(data.azurerm_subscription.data_sources_lookup[key].display_name, null)
        state           = try(data.azurerm_subscription.data_sources_lookup[key].state, null)
        tenant_id       = try(data.azurerm_subscription.data_sources_lookup[key].tenant_id, null)
      }
    )
  }

  azuread_groups_data_sources_static_resolved = {
    for key, value in local.azuread_groups_data_sources_static_lookup : key => merge(
      value,
      {
        id           = coalesce(try(value.id, null), try(value.object_id, null), try(value.rbac_id, null))
        object_id    = coalesce(try(value.object_id, null), try(value.id, null), try(value.rbac_id, null))
        rbac_id      = coalesce(try(value.rbac_id, null), try(value.object_id, null), try(value.id, null))
        display_name = try(value.display_name, null)
      }
    )
  }

  azuread_groups_data_sources_name_resolved = {
    for key, value in local.azuread_groups_data_sources_name_lookup : key => merge(
      value,
      {
        id           = data.azuread_group.data_sources_lookup[key].object_id
        object_id    = data.azuread_group.data_sources_lookup[key].object_id
        rbac_id      = data.azuread_group.data_sources_lookup[key].object_id
        display_name = data.azuread_group.data_sources_lookup[key].display_name
      }
    )
  }

  azuread_groups_data_sources_resolved = merge(
    local.azuread_groups_data_sources_static_resolved,
    local.azuread_groups_data_sources_name_resolved
  )

  keyvaults_data_sources_resolved = {
    for key, value in local.keyvaults_data_sources_name_lookup : key => merge(
      value,
      {
        id        = data.azurerm_key_vault.data_sources_lookup[key].id
        name      = data.azurerm_key_vault.data_sources_lookup[key].name
        vault_uri = data.azurerm_key_vault.data_sources_lookup[key].vault_uri
        rbac_id   = data.azurerm_key_vault.data_sources_lookup[key].id
      }
    )
  }

  storage_accounts_data_sources_resolved = {
    for key, value in local.storage_accounts_data_sources_name_lookup : key => merge(
      value,
      {
        id                             = data.azurerm_storage_account.data_sources_lookup[key].id
        name                           = data.azurerm_storage_account.data_sources_lookup[key].name
        location                       = data.azurerm_storage_account.data_sources_lookup[key].location
        resource_group_name            = data.azurerm_storage_account.data_sources_lookup[key].resource_group_name
        primary_blob_endpoint          = try(data.azurerm_storage_account.data_sources_lookup[key].primary_blob_endpoint, null)
        primary_access_key             = try(data.azurerm_storage_account.data_sources_lookup[key].primary_access_key, null)
        primary_connection_string      = try(data.azurerm_storage_account.data_sources_lookup[key].primary_connection_string, null)
        primary_blob_connection_string = try(data.azurerm_storage_account.data_sources_lookup[key].primary_blob_connection_string, null)
        containers                     = try(value.containers, {})
        queues                         = try(value.queues, {})
        data_lake_filesystems          = try(value.data_lake_filesystems, {})
        file_share                     = try(value.file_share, {})
        identity                       = try(data.azurerm_storage_account.data_sources_lookup[key].identity, null)
        rbac_id                        = data.azurerm_storage_account.data_sources_lookup[key].id
      }
    )
  }

  recovery_vaults_data_sources_resolved = {
    for key, value in local.recovery_vaults_data_sources_name_lookup : key => merge(
      value,
      {
        id                   = data.azurerm_recovery_services_vault.data_sources_lookup[key].id
        name                 = data.azurerm_recovery_services_vault.data_sources_lookup[key].name
        resource_group_name  = data.azurerm_recovery_services_vault.data_sources_lookup[key].resource_group_name
        soft_delete_enabled  = try(data.azurerm_recovery_services_vault.data_sources_lookup[key].soft_delete_enabled, null)
        backup_policies      = try(value.backup_policies, {})
        replication_policies = try(value.replication_policies, {})
        rbac_id              = data.azurerm_recovery_services_vault.data_sources_lookup[key].id
      }
    )
  }

  vnets_data_sources_resolved = {
    for key, value in local.vnets_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_virtual_network.data_sources_lookup[key].id
        name                = data.azurerm_virtual_network.data_sources_lookup[key].name
        address_space       = data.azurerm_virtual_network.data_sources_lookup[key].address_space
        dns_servers         = data.azurerm_virtual_network.data_sources_lookup[key].dns_servers
        resource_group_name = data.azurerm_virtual_network.data_sources_lookup[key].resource_group_name
        location            = data.azurerm_virtual_network.data_sources_lookup[key].location
        subnets = merge(
          {
            for subnet_key, subnet in try(value.subnets, {}) : subnet_key => subnet
            if try(subnet.id, null) != null
          },
          {
            for lookup_key, subnet_meta in local.vnet_subnets_data_sources_name_lookup :
            subnet_meta.subnet_key => {
              id                   = data.azurerm_subnet.data_sources_lookup[lookup_key].id
              name                 = data.azurerm_subnet.data_sources_lookup[lookup_key].name
              resource_group_name  = data.azurerm_subnet.data_sources_lookup[lookup_key].resource_group_name
              virtual_network_name = data.azurerm_subnet.data_sources_lookup[lookup_key].virtual_network_name
            }
            if subnet_meta.vnet_key == key
          }
        )
      }
    )
  }
}
