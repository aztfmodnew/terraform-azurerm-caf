locals {
  arm_filename = "${path.module}/arm_site_config.json"

  app_settings = merge(
    var.settings.application_insight == null ? {} : {
      "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.settings.application_insight.instrumentation_key,
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.settings.application_insight.connection_string,
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
    },
    try(var.settings.app_settings, {}),
    try(local.dynamic_settings_to_process, {})
  )

}