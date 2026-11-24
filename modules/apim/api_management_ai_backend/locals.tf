locals {
  module_tag = {
    module = basename(abspath(path.module))
  }
  tags = merge(var.base_tags, local.module_tag, try(var.settings.tags, {}))

  apim_lz_key = coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)
  ai_lz_key   = coalesce(try(var.settings.ai_services.lz_key, null), var.client_config.landingzone_key)
  cognitive_lz_key = coalesce(
    try(var.settings.cognitive_services_account.lz_key, null),
    try(var.settings.cognitive_account_deployment.lz_key, null),
    try(var.settings.cognitive_deployment.lz_key, null),
    try(var.settings.cognitive_account_project.lz_key, null),
    var.client_config.landingzone_key
  )
  rg_lz_key = coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)

  referenced_apim = try(var.remote_objects.api_management[local.apim_lz_key][var.settings.api_management.key], null)
  resource_group_name = try(coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.api_management.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(var.remote_objects.resource_groups[local.rg_lz_key][var.settings.resource_group.key].name, null),
    try(local.referenced_apim.resource_group_name, null)
  ), null)
  apim_name = try(coalesce(
    try(var.settings.api_management.name, null),
    try(local.referenced_apim.name, null)
  ), null)
  api_management_id = coalesce(
    try(var.settings.api_management_id, null),
    try(var.settings.api_management.id, null),
    try(local.referenced_apim.id, null),
    format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ApiManagement/service/%s",
      try(var.client_config.subscription_id, ""),
      try(local.resource_group_name, ""),
    try(local.apim_name, ""))
  )

  ai_services_endpoint = try(
    var.remote_objects.ai_services[local.ai_lz_key][var.settings.ai_services.key].endpoint,
    try(var.settings.ai_services.endpoint, null)
  )
  cognitive_account_endpoint = try(
    var.remote_objects.cognitive_services_accounts[local.cognitive_lz_key][var.settings.cognitive_services_account.key].endpoint,
    try(var.settings.cognitive_services_account.endpoint, null)
  )
  deployment = try(coalesce(
    try(var.remote_objects.cognitive_deployment[local.cognitive_lz_key][var.settings.cognitive_deployment.key], null),
    try(var.remote_objects.cognitive_deployment[local.cognitive_lz_key][var.settings.cognitive_account_deployment.key], null)
  ), null)
  deployment_endpoint = try(coalesce(
    try(var.settings.cognitive_deployment.endpoint, null),
    try(var.settings.cognitive_account_deployment.endpoint, null),
    try(local.deployment.endpoint, null),
    try("${format("https://%s.openai.azure.com", regex("/accounts/([^/]+)/deployments/", local.deployment.id)[0])}/", null)
  ), null)
  project = try(var.remote_objects.cognitive_account_project[local.cognitive_lz_key][var.settings.cognitive_account_project.key], null)
  project_endpoint = try(coalesce(
    try(var.settings.cognitive_account_project.endpoint, null),
    try(local.project.endpoints[coalesce(try(var.settings.cognitive_account_project.endpoint_key, null), try(var.settings.endpoint_key, null), "project")], null),
    try(values(local.project.endpoints)[0], null)
  ), null)

  endpoint = coalesce(
    try(var.settings.endpoint, null),
    try(var.settings.url, null),
    local.ai_services_endpoint,
    local.cognitive_account_endpoint,
    local.deployment_endpoint,
    local.project_endpoint
  )
  endpoint_url = "${trimsuffix(local.endpoint, "/")}/${var.settings.endpoint_path == null ? "" : trimprefix(var.settings.endpoint_path, "/")}"

  managed_identity_lz_key = coalesce(try(var.settings.managed_identity.lz_key, null), var.client_config.landingzone_key)
  managed_identity = try(
    var.remote_objects.managed_identities[local.managed_identity_lz_key][var.settings.managed_identity.key],
    try(one([
      for identity in values(try(var.remote_objects.managed_identities[local.managed_identity_lz_key], {})) :
      identity if try(identity.name, null) == try(var.settings.managed_identity.name, null) ||
      try(identity.id, null) == try(var.settings.managed_identity.id, null)
    ]), null)
  )
  managed_identity_client_id = try(coalesce(
    try(var.settings.managed_identity.client_id, null),
    try(local.managed_identity.client_id, null)
  ), null)
  managed_identity_name = try(coalesce(
    try(var.settings.managed_identity.name, null),
    try(local.managed_identity.name, null)
  ), null)
  authentication_policy = local.managed_identity_client_id == null ? (
    "<authentication-managed-identity resource=\"https://cognitiveservices.azure.com\" />"
    ) : (
    "<authentication-managed-identity resource=\"https://cognitiveservices.azure.com\" client-id=\"${local.managed_identity_client_id}\" />"
  )
}
