resource "azuread_application" "app" {

  display_name = var.global_settings.passthrough ? format("%s", var.settings.application_name) : format("%v-%s", try(var.global_settings.prefixes[0], ""), var.settings.application_name)

  owners = [
    var.client_config.object_id
  ]

  identifier_uris                = try(var.settings.identifier_uris, null)
  sign_in_audience               = can(var.settings.available_to_other_tenants) || try(var.settings.sign_in_audience, null) != null ? try(var.settings.available_to_other_tenants, "AzureADMyOrg") : null
  fallback_public_client_enabled = try(var.settings.fallback_public_client_enabled, false)
  group_membership_claims        = try(var.settings.group_membership_claims, ["All"])
  prevent_duplicate_names        = try(var.settings.prevent_duplicate_names, false)

  dynamic "single_page_application" {
    for_each = try(var.settings.single_page_application, null) != null ? [1] : []

    content {
      redirect_uris = try(var.settings.single_page_application.redirect_uris, [])
    }
  }

  dynamic "api" {
    for_each = try(var.settings.api, null) != null ? [1] : []

    content {
      known_client_applications      = try(var.settings.api.known_client_applications, [])
      mapped_claims_enabled          = try(var.settings.api.mapped_claims_enabled, null)
      requested_access_token_version = try(var.settings.api.requested_access_token_version, null)

      dynamic "oauth2_permission_scope" {
        for_each = try(var.settings.api.oauth2_permission_scopes, [])
        content {
          admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
          admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
          id                         = oauth2_permission_scope.value.id
          enabled                    = try(oauth2_permission_scope.value.enabled, null)
          type                       = try(oauth2_permission_scope.value.type, null)
          user_consent_description   = try(oauth2_permission_scope.value.user_consent_description, null)
          user_consent_display_name  = try(oauth2_permission_scope.value.user_consent_display_name, null)
          value                      = try(oauth2_permission_scope.value.value, null)
        }
      }
    }
  }

  dynamic "required_resource_access" {
    for_each = var.azuread_api_permissions

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = {
          for key, resource in required_resource_access.value.resource_access : key => resource
        }

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  dynamic "optional_claims" {
    for_each = try(var.settings.optional_claims, null) != null ? [1] : []

    content {
      dynamic "access_token" {
        for_each = try(var.settings.optional_claims.access_token, {})
        content {
          name                  = access_token.value.name
          source                = try(access_token.value.source, null)
          essential             = try(access_token.value.essential, null)
          additional_properties = try(access_token.value.additional_properties, [])
        }
      }

      dynamic "id_token" {
        for_each = try(var.settings.optional_claims.id_token, {})
        content {
          name                  = id_token.value.name
          source                = try(id_token.value.source, null)
          essential             = try(id_token.value.essential, null)
          additional_properties = try(id_token.value.additional_properties, [])
        }
      }
    }
  }

  dynamic "web" {
    for_each = try(var.settings.web, null) != null ? [var.settings.web] : []

    content {
      homepage_url  = can(var.settings.homepage) || can(web.value.homepage_url) ? try(var.settings.homepage, web.value.homepage_url) : null
      logout_url    = can(var.settings.logout_url) || can(web.value.logout_url) ? try(var.settings.logout_url, web.value.logout_url) : null
      redirect_uris = can(var.settings.reply_urls) || can(web.value.redirect_uris) ? try(var.settings.reply_urls, web.value.redirect_uris) : null

      dynamic "implicit_grant" {
        for_each = try(web.value.implicit_grant, null) != null ? [web.value.implicit_grant] : []

        content {
          access_token_issuance_enabled = can(var.settings.oauth2_allow_implicit_flow) || can(implicit_grant.value.access_token_issuance_enabled) ? try(var.settings.oauth2_allow_implicit_flow, implicit_grant.value.access_token_issuance_enabled) : null
          id_token_issuance_enabled     = try(implicit_grant.value.id_token_issuance_enabled, null)
        }
      }
    }
  }
}

resource "azuread_service_principal" "app" {
  client_id                    = azuread_application.app.client_id
  app_role_assignment_required = try(var.settings.app_role_assignment_required, false)
  tags                         = try(var.settings.tags, null)
  owners = [
    var.client_config.object_id
  ]
}

resource "azuread_service_principal_password" "pwd" {
  service_principal_id = azuread_service_principal.app.id
  # value                = random_password.pwd.result
  end_date = timeadd(time_rotating.pwd.id, format("%sh", local.password_policy.expire_in_days * 24))

  rotate_when_changed = {
    rotation = time_rotating.pwd.id
  }

  lifecycle {
    #create_before_destroy = false
  }
}

locals {
  password_policy = try(var.settings.password_policy, var.password_policy)
}

resource "time_rotating" "pwd" {
  rotation_minutes = try(local.password_policy.rotation.mins, null)
  rotation_days    = try(local.password_policy.rotation.days, null)
  rotation_months  = try(local.password_policy.rotation.months, null)
  rotation_years   = try(local.password_policy.rotation.years, null)
}

# Will force the password to change every month
# resource "random_password" "pwd" {
#   keepers = {
#     frequency = time_rotating.pwd.id
#   }
#   length  = local.password_policy.length
#   special = local.password_policy.special
#   upper   = local.password_policy.upper
#   numeric = local.password_policy.number
# }
