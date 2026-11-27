# Split from variables.tf - group: integration

variable "event_hub_namespaces" {
  type    = any
  default = {}
}

variable "event_hubs" {
  type    = any
  default = {}
}

variable "automations" {
  type    = any
  default = {}
}

variable "automation_powershell72_module" {
  default = {}
}

variable "automation_schedules" {
  type    = any
  default = {}
}

variable "automation_runbooks" {
  type    = any
  default = {}
}

variable "automation_log_analytics_links" {
  type    = any
  default = {}
}

variable "event_hub_auth_rules" {
  type    = any
  default = {}
}

variable "event_hub_namespace_auth_rules" {
  type    = any
  default = {}
}

variable "event_hub_consumer_groups" {
  type    = any
  default = {}
}

variable "servicebus_namespaces" {
  default = {}
  type    = any
}

variable "servicebus_topics" {
  type    = any
  default = {}
}

variable "servicebus_queues" {
  type    = any
  default = {}
}

variable "azure_bots" {
  type    = any
  default = {}
}

variable "communication_services" {
  type    = any
  default = {}
}

variable "signalr_services" {
  type    = any
  default = {}
}

variable "api_management" {
  description = "Map of business-keyed settings for APIM service instances, including service tier, publisher information, networking, managed identities and endpoints. Each value follows modules/apim/api_management/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                = string
    publisher_name      = string
    publisher_email     = string
    sku_name            = string
    region              = optional(string)
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))

    additional_location = optional(object({
      location             = string
      capacity             = optional(number)
      zones                = optional(list(string))
      public_ip_address_id = optional(string)
      gateway_disabled     = optional(bool)
      virtual_network_configuration = optional(object({
        subnet_id  = optional(string)
        lz_key     = optional(string)
        vnet_key   = optional(string)
        subnet_key = optional(string)
      }))
    }))
    additional_locations = optional(map(object({
      location             = string
      capacity             = optional(number)
      zones                = optional(list(string))
      public_ip_address_id = optional(string)
      gateway_disabled     = optional(bool)
      virtual_network_configuration = optional(object({
        subnet_id  = optional(string)
        lz_key     = optional(string)
        vnet_key   = optional(string)
        subnet_key = optional(string)
      }))
    })), {})
    certificate = optional(object({
      encoded_certificate  = string
      store_name           = string
      certificate_password = optional(string)
    }))
    certificates = optional(map(object({
      encoded_certificate  = string
      store_name           = string
      certificate_password = optional(string)
    })), {})
    client_certificate_enabled = optional(bool)
    delegation = optional(object({
      subscriptions_enabled     = optional(bool)
      user_registration_enabled = optional(bool)
      url                       = optional(string)
      validation_key            = optional(string)
    }))
    gateway_disabled     = optional(bool)
    min_api_version      = optional(string)
    zones                = optional(list(string))
    public_ip_address_id = optional(string)
    public_ip_address = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    public_network_access_enabled = optional(bool, true)
    virtual_network_type          = optional(string, "None")
    virtual_network_configuration = optional(object({
      subnet_id  = optional(string)
      lz_key     = optional(string)
      vnet_key   = optional(string)
      subnet_key = optional(string)
    }))
    identity = optional(object({
      type                  = string
      identity_ids          = optional(list(string))
      managed_identity_keys = optional(list(string), [])
      remote                = optional(map(object({ managed_identity_keys = list(string) })), {})
    }))
    hostname_configuration = optional(object({
      managements = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      portals = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      developer_portals = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      proxies = optional(map(object({
        default_ssl_binding             = optional(bool)
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      scms = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      management = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      portal = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      developer_portal = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      proxy = optional(object({
        default_ssl_binding             = optional(bool)
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      scm = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
    }))
    management = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    portal = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    developer_portal = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    proxy = optional(object({
      default_ssl_binding             = optional(bool)
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    scm = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    notification_sender_email = optional(string)
    protocols = optional(object({
      http2_enabled = optional(bool)
      enable_http2  = optional(bool)
    }))
    security = optional(object({
      backend_ssl30_enabled                               = optional(bool)
      backend_tls10_enabled                               = optional(bool)
      backend_tls11_enabled                               = optional(bool)
      frontend_ssl30_enabled                              = optional(bool)
      frontend_tls10_enabled                              = optional(bool)
      frontend_tls11_enabled                              = optional(bool)
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool)
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool)
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool)
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool)
      tls_ecdheRsa_with_aes128_cbc_sha_ciphers_enabled    = optional(bool)
      tls_ecdheRsa_with_aes256_cbc_sha_ciphers_enabled    = optional(bool)
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool)
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool)
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool)
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool)
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool)
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool)
      triple_des_ciphers_enabled                          = optional(bool)
      enable_backend_ssl30                                = optional(bool)
      enable_backend_tls10                                = optional(bool)
      enable_backend_tls11                                = optional(bool)
      enable_frontend_ssl30                               = optional(bool)
      enable_frontend_tls10                               = optional(bool)
      enable_frontend_tls11                               = optional(bool)
      enable_triple_des_ciphers                           = optional(bool)
      disable_backend_ssl30                               = optional(bool)
      disable_backend_tls10                               = optional(bool)
      disable_backend_tls11                               = optional(bool)
      disable_frontend_ssl30                              = optional(bool)
      disable_frontend_tls10                              = optional(bool)
      disable_frontend_tls11                              = optional(bool)
    }))
    sign_in = optional(object({
      enabled = bool
    }))
    sign_up = optional(object({
      enabled = bool
      terms_of_service = optional(object({
        consent_required = bool
        enabled          = bool
        text             = optional(string)
      }))
    }))
    terms_of_service = optional(object({
      consent_required = bool
      enabled          = bool
      text             = optional(string)
    }))
    tenant_access = optional(object({
      enabled = bool
    }))
    tags                = optional(map(string), {})
    diagnostic_profiles = optional(map(any), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api" {
  description = "Map of business-keyed settings for API definitions, including revisions, protocols, backend URLs, imports and versioning. Each value follows modules/apim/api_management_api/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                = string
    revision            = string
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_type     = optional(string, "http")
    display_name = optional(string)
    path         = optional(string)
    protocols    = optional(list(string))
    description  = optional(string)
    contact = optional(object({
      email = optional(string)
      name  = optional(string)
      url   = optional(string)
    }))
    import = optional(object({
      content_format = string
      content_value  = string
      wsdl_selector = optional(object({
        service_name  = string
        endpoint_name = string
      }))
    }))
    license = optional(object({
      name = optional(string)
      url  = optional(string)
    }))
    oauth2_authorization = optional(object({
      authorization_server_name = string
      scope                     = optional(string)
    }))
    openid_authentication = optional(object({
      openid_provider_name         = string
      bearer_token_sending_methods = optional(list(string))
    }))
    service_url = optional(string)
    subscription_key_parameter_names = optional(object({
      header = string
      query  = string
    }))
    subscription_required = optional(bool, true)
    terms_of_service_url  = optional(string)
    version               = optional(string)
    version_set_id        = optional(string)
    revision_description  = optional(string)
    version_description   = optional(string)
    source_api_id         = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_diagnostic" {
  description = "Map of business-keyed settings for API-specific gateway telemetry, including logger selection, sampling and request/response logging. Each value follows modules/apim/api_management_api_diagnostic/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    identifier          = string
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management_logger = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      id     = optional(string)
    }))
    always_log_errors         = optional(bool)
    http_correlation_protocol = optional(string)
    log_client_ip             = optional(bool)
    sampling_percentage       = optional(number)
    verbosity                 = optional(string)
    operation_name_format     = optional(string, "Name")
    backend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    backend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    frontend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    frontend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}

}

variable "api_management_logger" {
  description = "Map of business-keyed settings for Telemetry destinations registered with APIM, such as Application Insights or Event Hubs, for use by diagnostic configurations. Each value follows modules/apim/api_management_logger/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name        = string
    buffered    = optional(bool)
    description = optional(string)
    resource_id = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key = optional(string)
    resource = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    application_insights = optional(object({
      key                 = optional(string)
      lz_key              = optional(string)
      name                = optional(string)
      instrumentation_key = optional(string)
      connection_string   = optional(string)
      identity_client_id  = optional(string)
    }))
    eventhub = optional(object({
      name                             = optional(string)
      event_hub_name                   = optional(string)
      event_hub_namespace_name         = optional(string)
      connection_string                = optional(string)
      endpoint_uri                     = optional(string)
      resource_id                      = optional(string)
      user_assigned_identity_client_id = optional(string)
      event_hub_namespace_key          = optional(string)
      event_hub_key                    = optional(string)
      authorization_rule_key           = optional(string)
      managed_identity_key             = optional(string)
      event_hub_namespace = optional(object({
        id           = optional(string)
        key          = optional(string)
        lz_key       = optional(string)
        name         = optional(string)
        endpoint_uri = optional(string)
      }))
      namespace = optional(object({
        id           = optional(string)
        key          = optional(string)
        lz_key       = optional(string)
        name         = optional(string)
        endpoint_uri = optional(string)
      }))
      event_hub = optional(object({
        id     = optional(string)
        key    = optional(string)
        lz_key = optional(string)
        name   = optional(string)
      }))
      hub = optional(object({
        id     = optional(string)
        key    = optional(string)
        lz_key = optional(string)
        name   = optional(string)
      }))
      authorization_rule = optional(object({
        key                       = optional(string)
        lz_key                    = optional(string)
        primary_connection_string = optional(string)
      }))
      event_hub_authorization_rule = optional(object({
        key                       = optional(string)
        lz_key                    = optional(string)
        primary_connection_string = optional(string)
      }))
      event_hub_namespace_authorization_rule = optional(object({
        key                       = optional(string)
        lz_key                    = optional(string)
        primary_connection_string = optional(string)
      }))
      managed_identity = optional(object({
        client_id = optional(string)
        key       = optional(string)
        lz_key    = optional(string)
      }))
      identity = optional(object({
        client_id = optional(string)
        key       = optional(string)
        lz_key    = optional(string)
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_operation" {
  description = "Map of business-keyed settings for HTTP operations within APIs, including methods, URL templates, parameters and request/response contracts. Each value follows modules/apim/api_management_api_operation/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    operation_id        = string
    display_name        = string
    method              = string
    url_template        = string
    description         = optional(string)
    api_management_name = optional(string)
    api_name            = optional(string)
    resource_group_name = optional(string)
    resource_group_key  = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    request = optional(object({
      description = optional(string)
      headers = optional(map(object({
        name          = string
        required      = bool
        type          = string
        description   = optional(string)
        default_value = optional(string)
        values        = optional(set(string))
        schema_id     = optional(string)
        type_name     = optional(string)
        examples = optional(map(object({
          name           = string
          summary        = optional(string)
          description    = optional(string)
          value          = optional(string)
          external_value = optional(string)
        })), {})
      })), {})
      query_parameters = optional(map(object({
        name          = string
        required      = bool
        type          = string
        description   = optional(string)
        default_value = optional(string)
        values        = optional(set(string))
        schema_id     = optional(string)
        type_name     = optional(string)
        examples = optional(map(object({
          name           = string
          summary        = optional(string)
          description    = optional(string)
          value          = optional(string)
          external_value = optional(string)
        })), {})
      })), {})
      representations = optional(map(object({
        content_type = string
        form_parameters = optional(map(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(set(string))
          schema_id     = optional(string)
          type_name     = optional(string)
          examples = optional(map(object({
            name           = string
            summary        = optional(string)
            description    = optional(string)
            value          = optional(string)
            external_value = optional(string)
          })), {})
        })), {})
        examples = optional(map(object({
          name           = string
          summary        = optional(string)
          description    = optional(string)
          value          = optional(string)
          external_value = optional(string)
        })), {})
        schema_id = optional(string)
        type_name = optional(string)
      })), {})
    }))
    responses = optional(map(object({
      status_code = number
      description = optional(string)
      headers = optional(map(object({
        name          = string
        required      = bool
        type          = string
        description   = optional(string)
        default_value = optional(string)
        values        = optional(set(string))
        schema_id     = optional(string)
        type_name     = optional(string)
        examples = optional(map(object({
          name           = string
          summary        = optional(string)
          description    = optional(string)
          value          = optional(string)
          external_value = optional(string)
        })), {})
      })), {})
      representations = optional(map(object({
        content_type = string
        form_parameters = optional(map(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(set(string))
          schema_id     = optional(string)
          type_name     = optional(string)
          examples = optional(map(object({
            name           = string
            summary        = optional(string)
            description    = optional(string)
            value          = optional(string)
            external_value = optional(string)
          })), {})
        })), {})
        examples = optional(map(object({
          name           = string
          summary        = optional(string)
          description    = optional(string)
          value          = optional(string)
          external_value = optional(string)
        })), {})
        schema_id = optional(string)
        type_name = optional(string)
      })), {})
    })), {})
    template_parameters = optional(map(object({
      name          = string
      required      = bool
      type          = string
      description   = optional(string)
      default_value = optional(string)
      values        = optional(set(string))
      schema_id     = optional(string)
      type_name     = optional(string)
      examples = optional(map(object({
        name           = string
        summary        = optional(string)
        description    = optional(string)
        value          = optional(string)
        external_value = optional(string)
      })), {})
    })), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_backend" {
  description = "Map of business-keyed settings for Upstream backend registrations used by APIM policies, including endpoint, authentication and TLS configuration. Each value follows modules/apim/api_management_backend/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name     = string
    protocol = string
    url      = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    circuit_breaker_rule = optional(object({
      name                       = string
      trip_duration              = string
      accept_retry_after_enabled = optional(bool)
      failure_condition = object({
        interval_duration = string
        count             = optional(number)
        percentage        = optional(number)
        error_reasons     = optional(list(string))
        status_code_range = optional(list(object({
          min = number
          max = number
        })), [])
      })
    }))
    credentials = optional(object({
      authorization = optional(object({
        parameter = optional(string)
        scheme    = optional(string)
      }))
      certificate = optional(list(string))
      header      = optional(map(string))
      query       = optional(map(string))
    }))
    description = optional(string)
    proxy = optional(object({
      url      = string
      username = optional(string)
      password = optional(string)
    }))
    resource_id = optional(string)
    server_x509_name = optional(object({
      issuer_certificate_thumbprint = string
      name                          = string
    }))
    service_fabric_cluster = optional(object({
      client_certificate_thumbprint    = optional(string)
      client_certificate_id            = optional(string)
      management_endpoints             = set(string)
      max_partition_resolution_retries = number
      server_certificate_thumbprints   = optional(set(string))
      server_x509_name = optional(set(object({
        issuer_certificate_thumbprint = string
        name                          = string
      })))
    }))
    title = optional(string)
    tls = optional(object({
      validate_certificate_chain = optional(bool)
      validate_certificate_name  = optional(bool)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_policy" {
  description = "Map of business-keyed settings for API-scope XML policies, supplied inline or through a publicly accessible policy document. Each value follows modules/apim/api_management_api_policy/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_operation_policy" {
  description = "Map of business-keyed settings for XML policies attached to individual API operations rather than an entire API. Each value follows modules/apim/api_management_api_operation_policy/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_operation = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_operation_tag" {
  description = "Map of business-keyed settings for Associations that label individual API operations with APIM tags. Each value follows modules/apim/api_management_api_operation_tag/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name         = string
    display_name = string
    api_operation = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_user" {
  description = "Map of business-keyed settings for Developer portal user accounts, including profile details, account state and credentials. Each value follows modules/apim/api_management_user/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    user_id      = string
    email        = string
    first_name   = string
    last_name    = string
    confirmation = optional(string)
    note         = optional(string)
    password     = optional(string)
    state        = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_custom_domain" {
  description = "Map of business-keyed settings for Custom hostnames and certificates for APIM service endpoints. Each value follows modules/apim/api_management_custom_domain/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      id     = optional(string)
    }))

    developer_portal = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    developer_portals = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    management = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    managements = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    portal = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    portals = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    gateway = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      certificate_request_key         = optional(string)
      lz_key                          = optional(string)
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
      default_ssl_binding             = optional(bool)
    }))
    gateways = optional(any)
    proxy    = optional(any)

    scm = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      certificate_request_key         = optional(string)
      lz_key                          = optional(string)
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    scms = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      certificate_request_key         = optional(string)
      lz_key                          = optional(string)
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_diagnostic" {
  description = "Map of business-keyed settings for Service-wide APIM gateway telemetry, including logger selection, sampling and request/response logging; these are distinct from Azure Monitor diagnostic settings. Each value follows modules/apim/api_management_diagnostic/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    identifier                = string
    always_log_errors         = optional(bool)
    http_correlation_protocol = optional(string)
    log_client_ip             = optional(bool)
    sampling_percentage       = optional(number)
    verbosity                 = optional(string)
    operation_name_format     = optional(string)
    api_management            = optional(object({ id = optional(string), name = optional(string), key = optional(string), lz_key = optional(string) }))
    resource_group            = optional(object({ id = optional(string), name = optional(string), key = optional(string), lz_key = optional(string) }))
    resource_group_key        = optional(string)
    api_management_logger     = optional(object({ id = optional(string), name = optional(string), key = optional(string), lz_key = optional(string) }))
    backend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    backend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    frontend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    frontend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_certificate" {
  description = "Map of business-keyed settings for Certificates registered with an APIM service from supplied certificate data or Key Vault references. Each value follows modules/apim/api_management_certificate/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    data     = optional(string)
    password = optional(string)
    key_vault_secret = optional(object({
      certificate_key         = optional(string)
      certificate_request_key = optional(string)
      lz_key                  = optional(string)
    }))
    key_vault_secret_id = optional(string)
    key_vault_id        = optional(string)
    key_vault_identity_client = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    key_vault_identity_client_id = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_gateway" {
  description = "Map of business-keyed settings for Self-hosted gateway registrations in APIM; deploying the gateway software is a separate operation. Each value follows modules/apim/api_management_gateway/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    description = optional(string)
    location_data = object({
      name     = string
      city     = optional(string)
      district = optional(string)
      region   = optional(string)
    })
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_gateway_api" {
  description = "Map of business-keyed settings for Associations that make existing APIs available through registered self-hosted gateways. Each value follows modules/apim/api_management_gateway_api/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_management_gateway = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management_api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_group" {
  description = "Map of business-keyed settings for Developer portal groups used to organize users and control access to APIM products. Each value follows modules/apim/api_management_group/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name         = string
    display_name = string
    description  = optional(string)
    external_id  = optional(string)
    type         = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
      id     = optional(string)
    }))
    resource_group_key = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_subscription" {
  description = "Map of business-keyed settings for APIM access subscriptions, including ownership, API/product scope, access keys and lifecycle state. Each value follows modules/apim/api_management_subscription/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    display_name    = string
    api_id          = optional(string)
    user_id         = optional(string)
    primary_key     = optional(string)
    secondary_key   = optional(string)
    subscription_id = optional(string)
    state           = optional(string, "submitted")
    allow_tracing   = optional(bool, true)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    product = optional(object({
      key        = optional(string)
      lz_key     = optional(string)
      product_id = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_product" {
  description = "Map of business-keyed settings for API product bundles, including publication status, subscription requirements and approval settings. Each value follows modules/apim/api_management_product/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    product_id            = string
    display_name          = string
    published             = bool
    subscription_required = optional(bool, true)
    approval_required     = optional(bool)
    subscriptions_limit   = optional(number)
    description           = optional(string)
    terms                 = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    policy = optional(object({
      xml_file    = optional(string)
      xml_content = optional(string)
      xml_link    = optional(string)
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_named_value" {
  description = "Map of business-keyed settings for Reusable policy values, including literal text, secrets and values retrieved through Key Vault references. Each value follows modules/apim/api_management_named_value/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                = string
    display_name        = string
    value               = optional(string)
    secret              = optional(bool, false)
    tags                = optional(list(string))
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    value_from_key_vault = optional(object({
      secret_id   = optional(string)
      secret_name = optional(string)
      key_vault = optional(object({
        key    = string
        lz_key = optional(string)
      }))
      identity_client_id = optional(string)
      managed_identity = optional(object({
        key    = string
        lz_key = optional(string)
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_release" {
  description = "Map of business-keyed settings for Releases that publish a selected API revision, with optional release notes. Each value follows modules/apim/api_management_api_release/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name   = string
    api_id = optional(string)
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    notes = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_schema" {
  description = "Map of business-keyed settings for API request/response schemas, supplied as schema content or supported structured definitions/components. Each value follows modules/apim/api_management_api_schema/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    schema_id           = string
    content_type        = string
    value               = optional(string)
    components          = optional(string)
    definitions         = optional(string)
    api_name            = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_tag" {
  description = "Map of business-keyed settings for Associations that label existing APIs with APIM tags. Each value follows modules/apim/api_management_api_tag/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_id = optional(string)
    name   = optional(string)
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    tag = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_tag_description" {
  description = "Map of business-keyed settings for API-specific tag descriptions and external documentation metadata. Each value follows modules/apim/api_management_api_tag_description/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_tag_id = optional(string)
    api_tag = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    description                        = optional(string)
    external_documentation_url         = optional(string)
    external_documentation_description = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_api_version_set" {
  description = "Map of business-keyed settings for Groups of related API versions, including how the version is selected through a path, header or query parameter. Each value follows modules/apim/api_management_api_version_set/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                = string
    display_name        = string
    versioning_scheme   = string
    description         = optional(string)
    version_header_name = optional(string)
    version_query_name  = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_gateway_certificate_authority" {
  description = "Map of business-keyed settings for Certificate authority trust configuration for certificates used by self-hosted APIM gateways. Each value follows modules/apim/api_management_gateway_certificate_authority/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_management_id = optional(string)
    certificate_name  = optional(string)
    gateway_name      = optional(string)
    is_trusted        = optional(bool)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    certificate = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    gateway = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_gateway_host_name_configuration" {
  description = "Map of business-keyed settings for Self-hosted gateway hostname bindings, including certificates, client certificate negotiation and TLS/HTTP settings. Each value follows modules/apim/api_management_gateway_host_name_configuration/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                               = string
    host_name                          = string
    api_management_id                  = optional(string)
    gateway_name                       = optional(string)
    certificate_id                     = optional(string)
    request_client_certificate_enabled = optional(bool)
    http2_enabled                      = optional(bool, true)
    tls10_enabled                      = optional(bool)
    tls11_enabled                      = optional(bool)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    gateway = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    certificate = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_global_schema" {
  description = "Map of business-keyed settings for Reusable service-level schema definitions, including their content type, schema content and documentation. Each value follows modules/apim/api_management_global_schema/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    schema_id           = string
    type                = string
    value               = string
    description         = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_group_user" {
  description = "Map of business-keyed settings for Membership associations between existing APIM developer portal users and groups. Each value follows modules/apim/api_management_group_user/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    user_id             = optional(string)
    group_name          = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    user = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_policy" {
  description = "Map of business-keyed settings for Service-scope XML policies applied across an APIM instance. Each value follows modules/apim/api_management_policy/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_policy_fragment" {
  description = "Map of business-keyed settings for Reusable service-scope XML policy fragments that other APIM policies can include. Each value follows modules/apim/api_management_policy_fragment/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name              = string
    value             = string
    format            = optional(string, "xml")
    description       = optional(string)
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_product_api" {
  description = "Map of business-keyed settings for Associations that include existing APIs in existing APIM products. Each value follows modules/apim/api_management_product_api/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_name            = optional(string)
    product_id          = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    product = optional(object({
      product_id = optional(string)
      id         = optional(string)
      name       = optional(string)
      key        = optional(string)
      lz_key     = optional(string)
    }))
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_product_group" {
  description = "Map of business-keyed settings for Associations that grant developer portal groups visibility and access to APIM products. Each value follows modules/apim/api_management_product_group/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    product_id          = optional(string)
    group_name          = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    product = optional(object({
      product_id = optional(string)
      id         = optional(string)
      name       = optional(string)
      key        = optional(string)
      lz_key     = optional(string)
    }))
    group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_product_tag" {
  description = "Map of business-keyed settings for Associations that label existing APIM products with service tags. Each value follows modules/apim/api_management_product_tag/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_management_product_id = optional(string)
    name                      = optional(string)
    api_management_name       = optional(string)
    resource_group_name       = optional(string)
    product = optional(object({
      product_id = optional(string)
      id         = optional(string)
      name       = optional(string)
      key        = optional(string)
      lz_key     = optional(string)
    }))
    tag = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_redis_cache" {
  description = "Map of business-keyed settings for External Redis cache connections registered with APIM; Redis instances are created separately. Each value follows modules/apim/api_management_redis_cache/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name              = string
    connection_string = optional(string)
    api_management_id = optional(string)
    cache_location    = optional(string, "default")
    description       = optional(string)
    redis_cache_id    = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    redis_cache = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_standalone_gateway" {
  description = "Map of business-keyed settings for Independently managed APIM gateway instances, including SKU, location and network attachment; these are distinct from self-hosted gateway registrations. Each value follows modules/apim/api_management_standalone_gateway/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                 = string
    location             = optional(string)
    region               = optional(string)
    resource_group_name  = optional(string)
    backend_subnet_id    = optional(string)
    virtual_network_type = optional(string)
    tags                 = optional(map(string))
    sku = object({
      name     = string
      capacity = optional(number, 1)
    })
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    subnet = optional(object({
      id       = optional(string)
      vnet_key = optional(string)
      key      = optional(string)
      lz_key   = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_tag" {
  description = "Map of business-keyed settings for Service-level tags used to categorize APIs, operations and products through the corresponding association collections. Each value follows modules/apim/api_management_tag/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name              = string
    display_name      = optional(string)
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "api_management_authorization_server" {
  description = "Map of business-keyed settings for Registrations of existing OAuth 2.0 authorization servers, including authorization/token endpoints and client authentication. Each value follows modules/apim/api_management_authorization_server/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                         = string
    display_name                 = string
    authorization_endpoint       = string
    authorization_methods        = set(string)
    client_id                    = string
    client_registration_endpoint = string
    grant_types                  = set(string)
    bearer_token_sending_methods = optional(set(string))
    client_authentication_method = optional(set(string))
    client_secret                = optional(string)
    default_scope                = optional(string)
    description                  = optional(string)
    resource_owner_password      = optional(string)
    resource_owner_username      = optional(string)
    support_state                = optional(bool)
    token_endpoint               = optional(string)
    token_body_parameter = optional(list(object({
      name  = string
      value = string
    })), [])
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_email_template" {
  description = "Map of business-keyed settings for Overrides of predefined APIM notification email templates, including template identifier, subject and message body. Each value follows modules/apim/api_management_email_template/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    template_name       = string
    subject             = string
    body                = string
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_identity_provider_aad" {
  description = "Map of business-keyed settings for Microsoft Entra ID sign-in configuration for the APIM developer portal, including application credentials and tenant selection. Each value follows modules/apim/api_management_identity_provider_aad/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    client_id           = string
    client_secret       = string
    allowed_tenants     = list(string)
    client_library      = optional(string)
    signin_tenant       = optional(string)
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_identity_provider_aadb2c" {
  description = "Map of business-keyed settings for Azure AD B2C sign-in configuration for the APIM developer portal, including application credentials, tenant and user-flow policies. Each value follows modules/apim/api_management_identity_provider_aadb2c/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    client_id              = string
    client_secret          = string
    allowed_tenant         = string
    authority              = string
    signin_tenant          = string
    signin_policy          = string
    signup_policy          = string
    client_library         = optional(string)
    password_reset_policy  = optional(string)
    profile_editing_policy = optional(string)
    api_management_name    = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_identity_provider_facebook" {
  description = "Map of business-keyed settings for Facebook sign-in configuration for the APIM developer portal using the registered application's credentials. Each value follows modules/apim/api_management_identity_provider_facebook/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    app_id              = string
    app_secret          = string
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_identity_provider_google" {
  description = "Map of business-keyed settings for Google sign-in configuration for the APIM developer portal using the registered application's credentials. Each value follows modules/apim/api_management_identity_provider_google/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    client_id           = string
    client_secret       = string
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_identity_provider_microsoft" {
  description = "Map of business-keyed settings for Microsoft account sign-in configuration for the APIM developer portal using the registered application's credentials. Each value follows modules/apim/api_management_identity_provider_microsoft/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    client_id           = string
    client_secret       = string
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_identity_provider_twitter" {
  description = "Map of business-keyed settings for Twitter sign-in configuration for the APIM developer portal using the registered application's credentials. Each value follows modules/apim/api_management_identity_provider_twitter/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_key             = string
    api_secret_key      = string
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_notification_recipient_email" {
  description = "Map of business-keyed settings for Email addresses subscribed to selected APIM notification types; these do not change the service publisher address. Each value follows modules/apim/api_management_notification_recipient_email/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    email             = string
    notification_type = string
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_notification_recipient_user" {
  description = "Map of business-keyed settings for Existing APIM users subscribed to selected notification types; user accounts are managed separately. Each value follows modules/apim/api_management_notification_recipient_user/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    notification_type = string
    user_id           = optional(string)
    user = optional(object({
      user_id = optional(string)
      key     = optional(string)
      lz_key  = optional(string)
    }))
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_openid_connect_provider" {
  description = "Map of business-keyed settings for Registrations of existing OpenID Connect providers, including metadata discovery endpoints and client credentials. Each value follows modules/apim/api_management_openid_connect_provider/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                = string
    display_name        = string
    client_id           = string
    client_secret       = string
    metadata_endpoint   = string
    description         = optional(string)
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_workspace" {
  description = "Map of business-keyed settings for Workspaces that organize APIs and related configuration within a shared APIM service. Each value follows modules/apim/api_management_workspace/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name              = string
    display_name      = string
    description       = optional(string)
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_workspace_api_version_set" {
  description = "Map of business-keyed settings for API version groupings and version-selection rules scoped to an APIM workspace. Each value follows modules/apim/api_management_workspace_api_version_set/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                        = string
    display_name                = string
    versioning_scheme           = string
    description                 = optional(string)
    version_header_name         = optional(string)
    version_query_name          = optional(string)
    api_management_workspace_id = optional(string)
    api_management_workspace = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_workspace_certificate" {
  description = "Map of business-keyed settings for Certificates registered within an APIM workspace from certificate data or Key Vault references. Each value follows modules/apim/api_management_workspace_certificate/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                    = string
    certificate_data_base64 = optional(string)
    password                = optional(string)
    key_vault_secret_id     = optional(string)
    key_vault_secret = optional(object({
      certificate_key         = optional(string)
      certificate_request_key = optional(string)
      lz_key                  = optional(string)
    }))
    user_assigned_identity_client_id = optional(string)
    secret_name                      = optional(string)
    key_vault = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    managed_identity = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    api_management_workspace_id = optional(string)
    api_management_workspace = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_workspace_named_value" {
  description = "Map of business-keyed settings for Workspace-scoped policy values, including plain text, secrets and Key Vault references. Each value follows modules/apim/api_management_workspace_named_value/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name         = string
    display_name = string
    secret       = optional(bool, false)
    tags         = optional(list(string))
    value        = optional(string)
    value_from_key_vault = optional(object({
      secret_id          = optional(string)
      identity_client_id = optional(string)
      secret_name        = optional(string)
      key_vault = optional(object({
        key    = string
        lz_key = optional(string)
      }))
      managed_identity = optional(object({
        key    = string
        lz_key = optional(string)
      }))
    }))
    api_management_workspace_id = optional(string)
    api_management_workspace = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_workspace_policy" {
  description = "Map of business-keyed settings for Workspace-scope XML policies, supplied inline or through a publicly accessible policy document. Each value follows modules/apim/api_management_workspace_policy/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    xml_content                 = optional(string)
    xml_link                    = optional(string)
    api_management_workspace_id = optional(string)
    api_management_workspace = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_workspace_policy_fragment" {
  description = "Map of business-keyed settings for Reusable XML policy fragments defined within an APIM workspace. Each value follows modules/apim/api_management_workspace_policy_fragment/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    name                        = string
    xml_content                 = string
    xml_format                  = optional(string, "xml")
    description                 = optional(string)
    api_management_workspace_id = optional(string)
    api_management_workspace = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  }))
  default = {}
}

variable "api_management_product_policy" {
  description = "Map of business-keyed settings for Product-scope XML policies managed independently of product creation; do not also manage the same policy through embedded product settings. Each value follows modules/apim/api_management_product_policy/variables.tf. Defaults to an empty map, which creates none."
  type = map(object({
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    product_id = optional(string)
    product = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}
}

variable "digital_twins_instances" {
  description = "Digital Twins Instances"
  type        = any
  default     = {}
}

variable "digital_twins_endpoint_eventhubs" {
  description = "Digital Twins Endpoints Eventhubs"
  type        = any
  default     = {}
}

variable "digital_twins_endpoint_eventgrids" {
  description = "Digital Twins Endpoints Eventgrid"
  type        = any
  default     = {}
}

variable "digital_twins_endpoint_servicebuses" {
  description = "Digital Twins Endpoints Service Bus"
  type        = any
  default     = {}
}

variable "eventgrid_domain" {
  type    = any
  default = {}
}

variable "eventgrid_topic" {
  type    = any
  default = {}
}

variable "eventgrid_event_subscription" {
  type    = any
  default = {}
}

variable "eventgrid_domain_topic" {
  type    = any
  default = {}
}

variable "eventgrid_system_topic" {
  type    = any
  default = {}
}

variable "eventgrid_system_event_subscription" {
  type    = any
  default = {}
}

variable "relay_hybrid_connection" {
  type    = any
  default = {}
}

variable "relay_namespace" {
  type    = any
  default = {}
}

variable "runbooks" {
  type    = any
  default = {}
}

variable "resource_provider_registration" {
  type    = any
  default = {}
}

variable "iot_security_solution" {
  type    = any
  default = {}
}

variable "iot_security_device_group" {
  type    = any
  default = {}
}

variable "iot_central_application" {
  type    = any
  default = {}
}

variable "iot_hub" {
  type    = any
  default = {}
}

variable "iot_hub_dps" {
  type    = any
  default = {}
}

variable "iot_hub_shared_access_policy" {
  type    = any
  default = {}
}

variable "iot_dps_certificate" {
  type    = any
  default = {}
}

variable "iot_dps_shared_access_policy" {
  type    = any
  default = {}
}

variable "iot_hub_consumer_groups" {
  type    = any
  default = {}
}

variable "iot_hub_certificate" {
  type    = any
  default = {}
}
