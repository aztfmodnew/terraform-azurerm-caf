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

  managed_local_identities = flatten([
    for managed_identity_key in try(var.settings.identity.managed_identity_keys, []) : [
      var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
    ]
  ])

  managed_remote_identities = flatten([
    for lz_key, value in try(var.settings.identity.remote, []) : [
      for managed_identity_key in value.managed_identity_keys : [
        var.remote_objects.managed_identities[lz_key][managed_identity_key].id
      ]
    ]
  ])

  managed_identities = concat(local.managed_local_identities, local.managed_remote_identities)

  dynamic_settings_to_process = {
    for setting in
    flatten(
      [
        for setting_name, resources in try(var.settings.dynamic_app_settings, {}) : [
          for resource_type_key, resource in resources : [
            for object_id_key, object_attributes in resource : {
              key   = setting_name
              value = try(var.remote_objects.combined_objects[resource_type_key][object_attributes.lz_key][object_id_key][object_attributes.attribute_key], var.remote_objects.combined_objects[resource_type_key][var.client_config.landingzone_key][object_id_key][object_attributes.attribute_key])
            }
          ]
        ]
      ]
    ) : setting.key => setting.value
  }
}
