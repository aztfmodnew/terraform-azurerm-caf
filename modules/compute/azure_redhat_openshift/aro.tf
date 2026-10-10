# Schema: https://learn.microsoft.com/en-us/azure/templates/microsoft.redhatopenshift/2025-07-25/openshiftclusters

resource "azurecaf_name" "aro_cluster" {
  name          = var.settings.name
  resource_type = "azurerm_redhat_openshift_cluster"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurecaf_name" "aro_domain" {
  name          = var.settings.cluster_profile.domain
  resource_type = "azurerm_redhat_openshift_domain"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurecaf_name" "aro_res_rg" {
  count         = can(var.settings.cluster_profile.resource_group.name) ? 1 : 0
  name          = var.settings.cluster_profile.resource_group.name
  resource_type = "azurerm_resource_group"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azapi_resource" "aro" {
  name                 = azurecaf_name.aro_cluster.result
  location             = var.location
  parent_id            = var.resource_group
  type                 = "Microsoft.RedHatOpenShift/openShiftClusters@2025-07-25"
  tags                 = local.tags
  ignore_null_property = true

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
    content {
      type         = identity.value.type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], identity.value.type) ? local.managed_identities : null
    }
  }

  body = {
    properties = {
      masterProfile           = local.master_profile
      workerProfiles          = local.worker_profiles
      servicePrincipalProfile = local.service_principal
      clusterProfile          = local.cluster_profile
      ingressProfiles         = local.ingress_profiles
      apiserverProfile        = local.api_server_profile
      networkProfile          = local.network_profile
      platformWorkloadIdentityProfile = try(var.settings.platform_workload_identity_profile, null) == null ? null : {
        upgradeableTo = try(var.settings.platform_workload_identity_profile.upgradeable_to, null)
        platformWorkloadIdentities = {
          for key, value in try(var.settings.platform_workload_identity_profile.platform_workload_identities, {}) :
          key => {
            resourceId = coalesce(
              try(value.resource_id, null),
              try(var.combined_resources.managed_identities[coalesce(try(value.managed_identity.lz_key, null), var.client_config.landingzone_key)][value.managed_identity.key].id, null)
            )
          }
        }
      }
    }
  }
  response_export_values = ["properties.apiserverProfile", "properties.consoleProfile", "properties.ingressProfiles", "properties.clusterProfile.version"]

  timeouts {
    create = try(var.settings.timeouts.create, "60m")
    read   = try(var.settings.timeouts.read, null)
    update = try(var.settings.timeouts.update, null)
    delete = try(var.settings.timeouts.delete, null)
  }
}
