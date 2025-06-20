# rule_set.tf
# Placeholder for azurerm_cdn_frontdoor_rule_set resource implementation

module "rule_set" {
  source          = "./rule_set"
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  settings        = var.settings
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  remote_objects  = var.remote_objects
}
