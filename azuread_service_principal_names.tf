#
# Azure AD Service Principal Names Data Sources
# This module provides data sources to resolve Azure AD service principals by their display names
#

data "azuread_service_principal" "service_principal_names" {
  for_each = try(local.azuread.azuread_service_principal_names, {})

  display_name = each.value.display_name
}

# Create a local that maps the data source results to the expected format
locals {
  azuread_service_principal_names_resolved = {
    for k, v in data.azuread_service_principal.service_principal_names : k => {
      id                           = v.object_id
      object_id                    = v.object_id
      client_id                    = v.client_id
      display_name                 = v.display_name
      rbac_id                      = v.object_id
      application_tenant_id        = v.application_tenant_id
      account_enabled              = v.account_enabled
      app_role_assignment_required = v.app_role_assignment_required
      service_principal_names      = v.service_principal_names
      tags                         = v.tags
      type                         = v.type
    }
  }
}

output "azuread_service_principal_names" {
  value = local.azuread_service_principal_names_resolved
}
