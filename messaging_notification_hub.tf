module "notification_hub_namespaces" {
  source   = "./modules/messaging/notification_hub"
  for_each = local.messaging.notification_hub_namespaces

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    resource_groups = local.combined_objects_resource_groups
  }
}

output "notification_hub_namespaces" {
  value = module.notification_hub_namespaces
}
