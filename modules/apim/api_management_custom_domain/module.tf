resource "azurerm_api_management_custom_domain" "apim" {
  api_management_id = var.api_management_id

  dynamic "developer_portal" {
    for_each = local.developer_portal_blocks

    content {
      host_name            = developer_portal.value.host_name
      certificate          = try(developer_portal.value.certificate, null)
      certificate_password = try(developer_portal.value.certificate_password, null)
      key_vault_certificate_id = try(coalesce(
        try(developer_portal.value.key_vault_certificate_id, null),
        try(developer_portal.value.key_vault_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(developer_portal.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][developer_portal.value.key_vault_certificate.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(developer_portal.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][developer_portal.value.key_vault_certificate.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(developer_portal.value.keyvault.lz_key, null), var.client_config.landingzone_key)][developer_portal.value.keyvault.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(developer_portal.value.keyvault.lz_key, null), var.client_config.landingzone_key)][developer_portal.value.keyvault.certificate_request_key].secret_id, null)
      ), null)
      negotiate_client_certificate = try(developer_portal.value.negotiate_client_certificate, null)
      ssl_keyvault_identity_client_id = try(coalesce(
        try(developer_portal.value.ssl_keyvault_identity_client_id, null),
        try(var.remote_objects.managed_identities[coalesce(try(developer_portal.value.managed_identity.lz_key, null), var.client_config.landingzone_key)][developer_portal.value.managed_identity.key].client_id, null)
      ), null)
    }
  }

  dynamic "management" {
    for_each = local.management_blocks

    content {
      host_name            = management.value.host_name
      certificate          = try(management.value.certificate, null)
      certificate_password = try(management.value.certificate_password, null)
      key_vault_certificate_id = try(coalesce(
        try(management.value.key_vault_certificate_id, null),
        try(management.value.key_vault_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(management.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][management.value.key_vault_certificate.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(management.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][management.value.key_vault_certificate.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(management.value.keyvault.lz_key, null), var.client_config.landingzone_key)][management.value.keyvault.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(management.value.keyvault.lz_key, null), var.client_config.landingzone_key)][management.value.keyvault.certificate_request_key].secret_id, null)
      ), null)
      negotiate_client_certificate = try(management.value.negotiate_client_certificate, null)
      ssl_keyvault_identity_client_id = try(coalesce(
        try(management.value.ssl_keyvault_identity_client_id, null),
        try(var.remote_objects.managed_identities[coalesce(try(management.value.managed_identity.lz_key, null), var.client_config.landingzone_key)][management.value.managed_identity.key].client_id, null)
      ), null)
    }
  }

  dynamic "portal" {
    for_each = local.portal_blocks

    content {
      host_name            = portal.value.host_name
      certificate          = try(portal.value.certificate, null)
      certificate_password = try(portal.value.certificate_password, null)
      key_vault_certificate_id = try(coalesce(
        try(portal.value.key_vault_certificate_id, null),
        try(portal.value.key_vault_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(portal.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][portal.value.key_vault_certificate.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(portal.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][portal.value.key_vault_certificate.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(portal.value.keyvault.lz_key, null), var.client_config.landingzone_key)][portal.value.keyvault.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(portal.value.keyvault.lz_key, null), var.client_config.landingzone_key)][portal.value.keyvault.certificate_request_key].secret_id, null)
      ), null)
      negotiate_client_certificate = try(portal.value.negotiate_client_certificate, null)
      ssl_keyvault_identity_client_id = try(coalesce(
        try(portal.value.ssl_keyvault_identity_client_id, null),
        try(var.remote_objects.managed_identities[coalesce(try(portal.value.managed_identity.lz_key, null), var.client_config.landingzone_key)][portal.value.managed_identity.key].client_id, null)
      ), null)
    }
  }

  dynamic "gateway" {
    for_each = local.gateway_blocks

    content {
      host_name            = gateway.value.host_name
      certificate          = try(gateway.value.certificate, null)
      certificate_password = try(gateway.value.certificate_password, null)
      key_vault_certificate_id = try(coalesce(
        try(gateway.value.key_vault_certificate_id, null),
        try(gateway.value.key_vault_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(gateway.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][gateway.value.key_vault_certificate.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(gateway.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][gateway.value.key_vault_certificate.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(gateway.value.keyvault.lz_key, null), var.client_config.landingzone_key)][gateway.value.keyvault.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(gateway.value.keyvault.lz_key, null), var.client_config.landingzone_key)][gateway.value.keyvault.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(gateway.value.lz_key, null), var.client_config.landingzone_key)][gateway.value.certificate_request_key].secret_id, null)
      ), null)
      default_ssl_binding          = try(gateway.value.default_ssl_binding, null)
      negotiate_client_certificate = try(gateway.value.negotiate_client_certificate, null)
      ssl_keyvault_identity_client_id = try(coalesce(
        try(gateway.value.ssl_keyvault_identity_client_id, null),
        try(var.remote_objects.managed_identities[coalesce(try(gateway.value.managed_identity.lz_key, null), var.client_config.landingzone_key)][gateway.value.managed_identity.key].client_id, null)
      ), null)
    }
  }

  dynamic "scm" {
    for_each = local.scm_blocks

    content {
      host_name            = scm.value.host_name
      certificate          = try(scm.value.certificate, null)
      certificate_password = try(scm.value.certificate_password, null)
      key_vault_certificate_id = try(coalesce(
        try(scm.value.key_vault_certificate_id, null),
        try(scm.value.key_vault_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(scm.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][scm.value.key_vault_certificate.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(scm.value.key_vault_certificate.lz_key, null), var.client_config.landingzone_key)][scm.value.key_vault_certificate.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificates[coalesce(try(scm.value.keyvault.lz_key, null), var.client_config.landingzone_key)][scm.value.keyvault.certificate_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(scm.value.keyvault.lz_key, null), var.client_config.landingzone_key)][scm.value.keyvault.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(scm.value.keyvault.lz_key, null), var.client_config.landingzone_key)][scm.value.certificate_request_key].secret_id, null),
        try(var.remote_objects.keyvault_certificate_requests[coalesce(try(scm.value.lz_key, null), var.client_config.landingzone_key)][scm.value.certificate_request_key].secret_id, null)
      ), null)
      negotiate_client_certificate = try(scm.value.negotiate_client_certificate, null)
      ssl_keyvault_identity_client_id = try(coalesce(
        try(scm.value.ssl_keyvault_identity_client_id, null),
        try(var.remote_objects.managed_identities[coalesce(try(scm.value.managed_identity.lz_key, null), var.client_config.landingzone_key)][scm.value.managed_identity.key].client_id, null)
      ), null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
