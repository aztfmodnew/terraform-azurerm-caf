# Source: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana
# Validation: MCP Terraform (providerDocID: 10170113) - All attributes validated
resource "azurerm_dashboard_grafana" "grafana" {
  name                = azurecaf_name.grafana.result
  resource_group_name = local.resource_group_name
  location            = local.location

  # Required argument (Grafana major version)
  grafana_major_version = try(var.settings.grafana_major_version, 11)

  # Optional arguments - validated against MCP Terraform schema
  api_key_enabled                        = try(var.settings.api_key_enabled, false)
  auto_generated_domain_name_label_scope = try(var.settings.auto_generated_domain_name_label_scope, "TenantReuse")
  deterministic_outbound_ip_enabled      = try(var.settings.deterministic_outbound_ip_enabled, false)
  public_network_access_enabled          = try(var.settings.public_network_access_enabled, true)
  sku                                    = try(var.settings.sku, "Standard")
  zone_redundancy_enabled                = try(var.settings.zone_redundancy_enabled, false)

  # Dynamic block for SMTP configuration
  dynamic "smtp" {
    for_each = try(var.settings.smtp, null) == null ? [] : [var.settings.smtp]

    content {
      enabled                   = try(smtp.value.enabled, false)
      host                      = smtp.value.host
      user                      = smtp.value.user
      password                  = smtp.value.password
      start_tls_policy          = smtp.value.start_tls_policy
      from_address              = smtp.value.from_address
      from_name                 = try(smtp.value.from_name, "Azure Managed Grafana Notification")
      verification_skip_enabled = try(smtp.value.verification_skip_enabled, false)
    }
  }

  # Dynamic block for Azure Monitor Workspace integrations
  dynamic "azure_monitor_workspace_integrations" {
    for_each = try(var.settings.azure_monitor_workspace_integrations, [])

    content {
      resource_id = coalesce(
        try(azure_monitor_workspace_integrations.value.resource_id, null),
        try(var.remote_objects.azure_monitor_workspaces[
          try(azure_monitor_workspace_integrations.value.lz_key, var.client_config.landingzone_key)
        ][azure_monitor_workspace_integrations.value.key].id, null)
      )
    }
  }

  # Dynamic block for identity
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type = identity.value.type
      identity_ids = contains(["userassigned", "systemassigned, userassigned"], lower(identity.value.type)) ? coalesce(
        try(identity.value.identity_ids, null),
        try([
          for key in try(identity.value.managed_identity_keys, []) :
          var.remote_objects.managed_identities[try(identity.value.lz_key, var.client_config.landingzone_key)][key].id
        ], null)
      ) : null
    }
  }

  # Dynamic block for timeouts
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, "30m")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }

  tags = merge(local.tags, try(var.settings.tags, null))
}
