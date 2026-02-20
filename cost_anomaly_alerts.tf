module "cost_anomaly_alerts" {
  source   = "./modules/cost_management/cost_anomaly_alert"
  for_each = local.shared_services.cost_anomaly_alerts

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
}

output "cost_anomaly_alerts" {
  value = module.cost_anomaly_alerts
}
