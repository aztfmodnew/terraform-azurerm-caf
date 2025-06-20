module "origin" {
  source          = "./origin"
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  settings        = var.settings
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  remote_objects  = var.remote_objects
}
