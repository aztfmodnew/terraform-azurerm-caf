diagnostic_log_analytics = {
  central_logs_region1 = {
    region             = "region1"
    name               = "central_logs"
    resource_group_key = "nsp_re1"
  }
}

diagnostics_destinations = {
  log_analytics = {
    central_logs = {
      log_analytics_key              = "central_logs_region1"
      log_analytics_destination_type = "Dedicated"
    }
  }
}


diagnostics_definition = {
  network_security_perimeter = {
    name = "operational_logs_and_metrics"
    categories = {
      log = [
        # https://docs.azure.cn/en-us/azure-monitor/reference/supported-logs/microsoft-network-networksecurityperimeters-logs
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        #["allLogs", true, false, 0],
        ["NspCrossPerimeterInboundAllowed", true, false, 0],
        ["NspCrossPerimeterOutboundAllowed", true, false, 0],
        ["NspIntraPerimeterInboundAllowed", true, false, 0],
        ["NspOutboundAttempt", true, false, 0],
        ["NspPrivateInboundAllowed", true, false, 0],
        ["NspPublicInboundPerimeterRulesAllowed", true, false, 0],
        ["NspPublicInboundPerimeterRulesDenied", true, false, 0],
        ["NspPublicInboundResourceRulesAllowed", true, false, 0],
        ["NspPublicInboundResourceRulesDenied", true, false, 0],
        ["NspPublicOutboundPerimeterRulesAllowed", true, false, 0],
        ["NspPublicOutboundPerimeterRulesDenied", true, false, 0],
        ["NspPublicOutboundResourceRulesAllowed", true, false, 0],
        ["NspPublicOutboundResourceRulesDenied", true, false, 0],
      ]
      #metric = [
      #  #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
      #  ["AllMetrics", true, false, 0],
      #]
    }
  }
}
