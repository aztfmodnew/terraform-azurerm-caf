locals {
  arm_filename = "${path.module}/arm_site_config.json"

  app_settings = merge(
    var.application_insight == null ? {} : {
      "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.application_insight.instrumentation_key,
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insight.connection_string,
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
    },
    try(var.app_settings, {}),
    try(local.dynamic_settings_to_process, {})
  )

}