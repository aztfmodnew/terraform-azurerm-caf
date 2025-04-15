locals {
  arm_filename = "${path.module}/arm_site_config.json"

  app_settings = merge(
    try(var.settings.application_insight, null) == null ? {} : {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = try(
        var.remote_objects.application_insights[var.settings.application_insights.lz_key][var.settings.application_insights.key].instrumentation_key,
        var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insights.key].instrumentation_key,
        var.settings.application_insights.instrumentation_key,
      null),
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = try(
        var.remote_objects.application_insights[var.settings.application_insights.lz_key][var.settings.application_insights.key].connection_string,
        var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insights.key].connection_string,
        var.settings.application_insights.connection_string,
      null),
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    },
    try(var.settings.app_settings, {}),
    try(local.dynamic_settings_to_process, {}),
  )
}