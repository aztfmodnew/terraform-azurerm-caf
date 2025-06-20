# security_policy.tf
module "security_policy" {
  source          = "./security_policy"
  for_each        = try(var.settings.security_policies, {})
  global_settings = var.global_settings
  client_config   = var.client_config
  settings        = each.value
  remote_objects = {
    cdn_frontdoor_profile_id    = var.remote_objects.cdn_frontdoor_profile_id
    cdn_frontdoor_waf_policy_id = var.remote_objects.cdn_frontdoor_waf_policy_id
  }

}
