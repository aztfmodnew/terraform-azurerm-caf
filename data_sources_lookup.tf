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

  management_groups_data_sources_name_lookup = {
    for key, value in try(var.data_sources.management_groups, {}) : key => value
    if try(value.id, null) == null && (
      try(value.name, null) != null ||
      try(value.display_name, null) != null
    )
  }

  subscriptions_data_sources_lookup = {
    for key, value in try(var.data_sources.subscriptions, {}) : key => value
    if try(value.id, null) == null && try(value.subscription_id, null) != null
  }

  role_definitions_data_sources_lookup = {
    for key, value in try(var.data_sources.role_definitions, {}) : key => value
    if try(value.id, null) == null && (
      try(value.name, null) != null ||
      try(value.role_definition_id, null) != null
    )
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

  managed_identities_data_sources_name_lookup = {
    for key, value in try(var.data_sources.managed_identities, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  private_dns_data_sources_name_lookup = {
    for key, value in try(var.data_sources.private_dns, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null
  }

  public_ip_addresses_data_sources_name_lookup = {
    for key, value in try(var.data_sources.public_ip_addresses, {}) : key => value
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

  virtual_subnets_data_sources_name_lookup = {
    for key, value in try(var.data_sources.virtual_subnets, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.virtual_network_name, null) != null && try(value.resource_group_name, null) != null
  }
}

data "azurerm_resource_group" "data_sources_lookup" {
  for_each = local.resource_groups_data_sources_name_lookup

  name = each.value.name
}

data "azurerm_management_group" "data_sources_lookup" {
  for_each = local.management_groups_data_sources_name_lookup

  name         = try(each.value.name, null)
  display_name = try(each.value.display_name, null)
}

data "azurerm_subscription" "data_sources_lookup" {
  for_each = local.subscriptions_data_sources_lookup

  subscription_id = each.value.subscription_id
}

data "azurerm_role_definition" "data_sources_lookup" {
  for_each = local.role_definitions_data_sources_lookup

  name               = try(each.value.name, null)
  role_definition_id = try(each.value.role_definition_id, null)
  scope              = try(each.value.scope, null)
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

data "azurerm_user_assigned_identity" "data_sources_lookup" {
  for_each = local.managed_identities_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_private_dns_zone" "data_sources_lookup" {
  for_each = local.private_dns_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = try(each.value.resource_group_name, null)
}

data "azurerm_public_ip" "data_sources_lookup" {
  for_each = local.public_ip_addresses_data_sources_name_lookup

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

data "azurerm_subnet" "virtual_subnets_data_sources_lookup" {
  for_each = local.virtual_subnets_data_sources_name_lookup

  name                 = each.value.name
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

  management_groups_data_sources_resolved = {
    for key, value in local.management_groups_data_sources_name_lookup : key => merge(
      value,
      {
        id                         = data.azurerm_management_group.data_sources_lookup[key].id
        display_name               = try(data.azurerm_management_group.data_sources_lookup[key].display_name, null)
        tenant_scoped_id           = try(data.azurerm_management_group.data_sources_lookup[key].tenant_scoped_id, null)
        parent_management_group_id = try(data.azurerm_management_group.data_sources_lookup[key].parent_management_group_id, null)
        management_group_ids       = try(data.azurerm_management_group.data_sources_lookup[key].management_group_ids, null)
        subscription_ids           = try(data.azurerm_management_group.data_sources_lookup[key].subscription_ids, null)
        all_management_group_ids   = try(data.azurerm_management_group.data_sources_lookup[key].all_management_group_ids, null)
        all_subscription_ids       = try(data.azurerm_management_group.data_sources_lookup[key].all_subscription_ids, null)
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

  role_definitions_data_sources_resolved = {
    for key, value in local.role_definitions_data_sources_lookup : key => merge(
      value,
      {
        id                = data.azurerm_role_definition.data_sources_lookup[key].id
        name              = try(data.azurerm_role_definition.data_sources_lookup[key].name, try(value.name, null))
        role_definition_id = coalesce(
          try(value.role_definition_id, null),
          try(
            element(
              regexall("[0-9a-fA-F-]{36}", data.azurerm_role_definition.data_sources_lookup[key].id),
              length(regexall("[0-9a-fA-F-]{36}", data.azurerm_role_definition.data_sources_lookup[key].id)) - 1
            ),
            null
          )
        )
        description       = try(data.azurerm_role_definition.data_sources_lookup[key].description, null)
        assignable_scopes = try(data.azurerm_role_definition.data_sources_lookup[key].assignable_scopes, null)
        scope             = try(value.scope, null)
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

  managed_identities_data_sources_resolved = {
    for key, value in local.managed_identities_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_user_assigned_identity.data_sources_lookup[key].id
        name                = data.azurerm_user_assigned_identity.data_sources_lookup[key].name
        resource_group_name = value.resource_group_name
        location            = data.azurerm_user_assigned_identity.data_sources_lookup[key].location
        principal_id        = try(data.azurerm_user_assigned_identity.data_sources_lookup[key].principal_id, null)
        client_id           = try(data.azurerm_user_assigned_identity.data_sources_lookup[key].client_id, null)
        tenant_id           = try(data.azurerm_user_assigned_identity.data_sources_lookup[key].tenant_id, null)
        tags                = try(data.azurerm_user_assigned_identity.data_sources_lookup[key].tags, null)
        rbac_id             = data.azurerm_user_assigned_identity.data_sources_lookup[key].id
      }
    )
  }

  private_dns_data_sources_resolved = {
    for key, value in local.private_dns_data_sources_name_lookup : key => merge(
      value,
      {
        id                                                  = data.azurerm_private_dns_zone.data_sources_lookup[key].id
        name                                                = data.azurerm_private_dns_zone.data_sources_lookup[key].name
        resource_group_name                                 = try(value.resource_group_name, null)
        max_number_of_record_sets                           = try(data.azurerm_private_dns_zone.data_sources_lookup[key].max_number_of_record_sets, null)
        max_number_of_virtual_network_links                 = try(data.azurerm_private_dns_zone.data_sources_lookup[key].max_number_of_virtual_network_links, null)
        max_number_of_virtual_network_links_with_registration = try(data.azurerm_private_dns_zone.data_sources_lookup[key].max_number_of_virtual_network_links_with_registration, null)
        number_of_record_sets                               = try(data.azurerm_private_dns_zone.data_sources_lookup[key].number_of_record_sets, null)
        tags                                                = try(data.azurerm_private_dns_zone.data_sources_lookup[key].tags, null)
        rbac_id                                             = data.azurerm_private_dns_zone.data_sources_lookup[key].id
      }
    )
  }

  public_ip_addresses_data_sources_resolved = {
    for key, value in local.public_ip_addresses_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_public_ip.data_sources_lookup[key].id
        name                = data.azurerm_public_ip.data_sources_lookup[key].name
        resource_group_name = value.resource_group_name
        location            = try(data.azurerm_public_ip.data_sources_lookup[key].location, null)
        ip_address          = try(data.azurerm_public_ip.data_sources_lookup[key].ip_address, null)
        fqdn                = try(data.azurerm_public_ip.data_sources_lookup[key].fqdn, null)
        domain_name_label   = try(data.azurerm_public_ip.data_sources_lookup[key].domain_name_label, null)
        allocation_method   = try(data.azurerm_public_ip.data_sources_lookup[key].allocation_method, null)
        sku                 = try(data.azurerm_public_ip.data_sources_lookup[key].sku, null)
        zones               = try(data.azurerm_public_ip.data_sources_lookup[key].zones, null)
        tags                = try(data.azurerm_public_ip.data_sources_lookup[key].tags, null)
        rbac_id             = data.azurerm_public_ip.data_sources_lookup[key].id
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

  virtual_subnets_data_sources_resolved = {
    for key, value in local.virtual_subnets_data_sources_name_lookup : key => merge(
      value,
      {
        id                                     = data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].id
        name                                   = data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].name
        resource_group_name                    = data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].resource_group_name
        virtual_network_name                   = data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].virtual_network_name
        address_prefixes                       = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].address_prefixes, null)
        network_security_group_id              = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].network_security_group_id, null)
        route_table_id                         = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].route_table_id, null)
        service_endpoints                      = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].service_endpoints, null)
        default_outbound_access_enabled        = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].default_outbound_access_enabled, null)
        private_endpoint_network_policies      = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].private_endpoint_network_policies, null)
        private_link_service_network_policies_enabled = try(data.azurerm_subnet.virtual_subnets_data_sources_lookup[key].private_link_service_network_policies_enabled, null)
      }
    )
  }
}

# =============================================================================
# Batch 2: log_analytics, application_insights, service_plans, cosmos_dbs,
#          mssql_servers
# =============================================================================

locals {
  # ---------------------------------------------------------------------------
  # log_analytics
  # ---------------------------------------------------------------------------
  log_analytics_data_sources_name_lookup = {
    for key, value in try(var.data_sources.log_analytics, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  # ---------------------------------------------------------------------------
  # application_insights  (key in var.data_sources: "azurerm_application_insights")
  # ---------------------------------------------------------------------------
  application_insights_data_sources_name_lookup = {
    for key, value in try(var.data_sources.azurerm_application_insights, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  # ---------------------------------------------------------------------------
  # service_plans
  # ---------------------------------------------------------------------------
  service_plans_data_sources_name_lookup = {
    for key, value in try(var.data_sources.service_plans, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  # ---------------------------------------------------------------------------
  # cosmos_dbs
  # ---------------------------------------------------------------------------
  cosmos_dbs_data_sources_name_lookup = {
    for key, value in try(var.data_sources.cosmos_dbs, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }

  # ---------------------------------------------------------------------------
  # mssql_servers
  # ---------------------------------------------------------------------------
  mssql_servers_data_sources_name_lookup = {
    for key, value in try(var.data_sources.mssql_servers, {}) : key => value
    if try(value.id, null) == null && try(value.name, null) != null && try(value.resource_group_name, null) != null
  }
}

data "azurerm_log_analytics_workspace" "data_sources_lookup" {
  for_each = local.log_analytics_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_application_insights" "data_sources_lookup" {
  for_each = local.application_insights_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_service_plan" "data_sources_lookup" {
  for_each = local.service_plans_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_cosmosdb_account" "data_sources_lookup" {
  for_each = local.cosmos_dbs_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_mssql_server" "data_sources_lookup" {
  for_each = local.mssql_servers_data_sources_name_lookup

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

locals {
  log_analytics_data_sources_resolved = {
    for key, value in local.log_analytics_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_log_analytics_workspace.data_sources_lookup[key].id
        name                = data.azurerm_log_analytics_workspace.data_sources_lookup[key].name
        location            = data.azurerm_log_analytics_workspace.data_sources_lookup[key].location
        resource_group_name = data.azurerm_log_analytics_workspace.data_sources_lookup[key].resource_group_name
        workspace_id        = try(data.azurerm_log_analytics_workspace.data_sources_lookup[key].workspace_id, null)
        primary_shared_key  = try(data.azurerm_log_analytics_workspace.data_sources_lookup[key].primary_shared_key, null)
        rbac_id             = data.azurerm_log_analytics_workspace.data_sources_lookup[key].id
      }
    )
  }

  application_insights_data_sources_resolved = {
    for key, value in local.application_insights_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_application_insights.data_sources_lookup[key].id
        name                = data.azurerm_application_insights.data_sources_lookup[key].name
        resource_group_name = try(data.azurerm_application_insights.data_sources_lookup[key].resource_group_name, null)
        app_id              = try(data.azurerm_application_insights.data_sources_lookup[key].app_id, null)
        instrumentation_key = try(data.azurerm_application_insights.data_sources_lookup[key].instrumentation_key, null)
        connection_string   = try(data.azurerm_application_insights.data_sources_lookup[key].connection_string, null)
        rbac_id             = data.azurerm_application_insights.data_sources_lookup[key].id
      }
    )
  }

  service_plans_data_sources_resolved = {
    for key, value in local.service_plans_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_service_plan.data_sources_lookup[key].id
        name                = data.azurerm_service_plan.data_sources_lookup[key].name
        location            = data.azurerm_service_plan.data_sources_lookup[key].location
        resource_group_name = data.azurerm_service_plan.data_sources_lookup[key].resource_group_name
        kind                = try(data.azurerm_service_plan.data_sources_lookup[key].kind, null)
        reserved            = try(data.azurerm_service_plan.data_sources_lookup[key].reserved, null)
        rbac_id             = data.azurerm_service_plan.data_sources_lookup[key].id
      }
    )
  }

  cosmos_dbs_data_sources_resolved = {
    for key, value in local.cosmos_dbs_data_sources_name_lookup : key => merge(
      value,
      {
        id                  = data.azurerm_cosmosdb_account.data_sources_lookup[key].id
        name                = data.azurerm_cosmosdb_account.data_sources_lookup[key].name
        location            = data.azurerm_cosmosdb_account.data_sources_lookup[key].location
        resource_group_name = data.azurerm_cosmosdb_account.data_sources_lookup[key].resource_group_name
        endpoint            = try(data.azurerm_cosmosdb_account.data_sources_lookup[key].endpoint, null)
        primary_key         = try(data.azurerm_cosmosdb_account.data_sources_lookup[key].primary_key, null)
        rbac_id             = data.azurerm_cosmosdb_account.data_sources_lookup[key].id
      }
    )
  }

  mssql_servers_data_sources_resolved = {
    for key, value in local.mssql_servers_data_sources_name_lookup : key => merge(
      value,
      {
        id                          = data.azurerm_mssql_server.data_sources_lookup[key].id
        name                        = data.azurerm_mssql_server.data_sources_lookup[key].name
        location                    = data.azurerm_mssql_server.data_sources_lookup[key].location
        resource_group_name         = data.azurerm_mssql_server.data_sources_lookup[key].resource_group_name
        fully_qualified_domain_name = try(data.azurerm_mssql_server.data_sources_lookup[key].fully_qualified_domain_name, null)
        rbac_id                     = data.azurerm_mssql_server.data_sources_lookup[key].id
      }
    )
  }
}
