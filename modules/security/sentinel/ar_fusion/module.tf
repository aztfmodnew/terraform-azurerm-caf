resource "azurerm_sentinel_alert_rule_fusion" "fusion" {
  log_analytics_workspace_id = var.log_analytics_workspace_id
  alert_rule_template_guid   = var.alert_rule_template_guid
  enabled                    = var.enabled
}
