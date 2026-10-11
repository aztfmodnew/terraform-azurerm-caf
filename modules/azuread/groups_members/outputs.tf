output "memberships" {
  description = "Membership modules by resolution mode, retaining stable source keys."
  value = {
    user_principal_names       = module.user_principal_names
    service_principals         = module.service_principals
    azuread_service_principals = module.azuread_service_principals
    object_ids                 = module.object_id
    group_names                = module.group_name
    group_keys                 = module.group_keys
    azuread_groups             = module.azuread_groups_membership
    service_principal_keys     = module.azuread_service_principals_membership
    managed_identities         = module.managed_identities_membership
    mssql_servers              = module.mssql_servers_membership
    membership_object_ids      = module.membership_object_id
    logged_in_object_ids       = module.membership_logged_in_object_id
  }
}
