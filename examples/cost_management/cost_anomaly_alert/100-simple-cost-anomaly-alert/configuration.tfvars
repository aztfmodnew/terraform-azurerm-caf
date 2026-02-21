global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

shared_services = {
  cost_anomaly_alerts = {
    alert1 = {
      name            = "example-cost-anomaly-alert"
      display_name    = "Example Cost Anomaly Alert"
      email_addresses = ["admin@example.com"]
      email_subject   = "Cost Anomaly Detected"
      message         = "A cost anomaly has been detected in your Azure subscription."
    }
  }
}
