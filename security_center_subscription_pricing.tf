module "security_center_subscription_pricings" {
  source   = "./modules/security/security_center/subscription_pricing"
  for_each = try(local.security.security_center_subscription_pricings, {})

  global_settings = local.global_settings
  client_config   = local.client_config
  base_tags       = local.global_settings.inherit_tags
  settings        = each.value
}

output "security_center_subscription_pricings" {
  value = module.security_center_subscription_pricings
}
