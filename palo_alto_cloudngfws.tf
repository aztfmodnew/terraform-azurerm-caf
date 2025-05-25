module "palo_alto_cloudngfws" {
  source   = "./modules/palo_alto/cloudngfw"
  for_each = local.palo_alto.cloudngfws

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null) # Can be overridden at the module call level
  settings        = each.value

  remote_objects = {
    # Add other remote objects if the sub-modules or main module require them
    diagnostics = local.combined_diagnostics
    # Note: The diagnostics module is not used in the Palo Alto NGFW module, but it's included for completeness.
    public_ip_addresses           = local.combined_objects_public_ip_addresses
    virtual_networks              = local.combined_objects_networking
    virtual_subnets               = local.combined_objects_virtual_subnets
    keyvault_certificates         = local.combined_objects_keyvault_certificates
    keyvault_certificate_requests = local.combined_objects_keyvault_certificate_requests



  }
}
output "palo_alto_cloudngfws" {
  value = module.palo_alto_cloudngfws
}
