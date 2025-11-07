locals {
  keyvault_certificates_logged_in_access = {
    for key, cfg in local.security.keyvault_certificates : key => cfg
    if try(cfg.ensure_logged_in_access, false) && local.client_config.logged_user_objectId != null
  }
}

resource "azurerm_role_assignment" "keyvault_certificates_logged_in" {
  for_each = local.keyvault_certificates_logged_in_access

  principal_id         = try(each.value.ensure_logged_in_principal_id, local.client_config.logged_user_objectId)
  role_definition_name = try(each.value.ensure_logged_in_role, "Key Vault Administrator")
  scope                = local.combined_objects_keyvaults[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.keyvault_key].id
}

resource "time_sleep" "keyvault_certificates_logged_in" {
  for_each      = length(local.keyvault_certificates_logged_in_access) > 0 ? { wait = true } : {}
  depends_on    = [azurerm_role_assignment.keyvault_certificates_logged_in]
  create_duration = "3m"
}

module "keyvault_certificates" {
  source     = "./modules/security/keyvault_certificate"
  depends_on = [
    module.keyvaults,
    module.keyvault_access_policies,
    time_sleep.keyvault_certificates_logged_in
  ]

  for_each = local.security.keyvault_certificates

  settings = each.value
  keyvault = local.combined_objects_keyvaults[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.keyvault_key]
}

output "keyvault_certificates" {
  value = module.keyvault_certificates
}