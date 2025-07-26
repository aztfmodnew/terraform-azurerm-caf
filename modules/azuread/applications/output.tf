
output "tenant_id" {
  value = var.client_config.tenant_id

}

output "azuread_application" {
  value = {
    id        = azuread_application.app.id
    object_id = azuread_application.app.object_id
    client_id = azuread_application.app.client_id
    #deprecated
    #name           = azuread_application.app.name
  }

}

output "azuread_service_principal" {
  value = {
    id        = azuread_service_principal.app.id
    object_id = azuread_service_principal.app.object_id
  }

}

output "keyvaults" {
  value = {
    for key, value in try(var.settings.keyvaults, {}) : key => {
      id                        = azurerm_key_vault_secret.client_id[key].key_vault_id
      secret_name_client_secret = value.secret_prefix
    }
  }
}

output "rbac_id" {
  value       = azuread_service_principal.app.object_id
  description = "This attribute is used to set the role assignment"
}
# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
