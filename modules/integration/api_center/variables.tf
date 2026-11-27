variable "global_settings" {
  description = "CAF global naming, region, and tag settings."
  type        = any
}

variable "client_config" {
  description = "Landing-zone identity and subscription configuration."
  type        = any
}

variable "settings" {
  description = <<-DESCRIPTION
  Composed Azure API Center service and catalog. Use name, resource_group, and
  location to create a service, or select an existing service with service_id or
  service.id/key/lz_key. Set create_service explicitly when a direct service ID
  is not known until apply.

  The supported hierarchy is workspace -> environment/API -> version ->
  definition and deployment. All child collections are maps keyed by CAF
  business keys. Names are Azure API Center names (3-90 alphanumeric or hyphen
  characters). identity.type supports SystemAssigned, UserAssigned, or both.
  User-assigned identity IDs can be passed directly or resolved from CAF keys.

  Environments require title and kind and optionally contain server portal URIs,
  onboarding instructions, custom properties, and operation timeouts. APIs
  support descriptive OpenAPI metadata, versions, definitions, and deployments.
  Lifecycle stages are development, testing, production, deprecated, or retired;
  deployment states are active or inactive. Specifications and metadata schemas
  contain inline string values. Direct environment_id and definition_id values
  or generated resource IDs are normalized to service-relative deployment
  references. Undeclared attributes are discarded by this typed contract.
DESCRIPTION
  type = object({
    name           = optional(string)
    api_version    = optional(string, "2024-03-01")
    create_service = optional(bool)
    service_id     = optional(string)
    service = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      name     = optional(string)
      location = optional(string)
    }))
    resource_group_name = optional(string)
    region              = optional(string)
    location            = optional(string)
    tags                = optional(map(string), {})
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
      managed_identities = optional(list(object({
        id     = optional(string)
        key    = optional(string)
        lz_key = optional(string)
      })), [])
      managed_identity_keys = optional(list(string), [])
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    workspaces = optional(map(object({
      name        = string
      title       = string
      description = optional(string)
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
      environments = optional(map(object({
        name        = string
        title       = string
        kind        = string
        description = optional(string)
        server = optional(object({
          type                   = optional(string)
          management_portal_uri  = optional(string)
          management_portal_uris = optional(list(string))
        }))
        onboarding = optional(object({
          instructions          = optional(string)
          developer_portal_uri  = optional(string)
          developer_portal_uris = optional(list(string))
        }))
        custom_properties = optional(map(string))
        timeouts = optional(object({
          create = optional(string)
          read   = optional(string)
          update = optional(string)
          delete = optional(string)
        }))
      })), {})
      apis = optional(map(object({
        name        = string
        title       = string
        kind        = string
        description = optional(string)
        summary     = optional(string)
        terms_of_service = optional(object({
          url = string
        }))
        external_documentation = optional(list(object({
          url         = string
          title       = optional(string)
          description = optional(string)
        })))
        contacts = optional(list(object({
          name  = optional(string)
          url   = optional(string)
          email = optional(string)
        })))
        license = optional(object({
          name       = optional(string)
          url        = optional(string)
          identifier = optional(string)
        }))
        custom_properties = optional(map(string))
        timeouts = optional(object({
          create = optional(string)
          read   = optional(string)
          update = optional(string)
          delete = optional(string)
        }))
        versions = optional(map(object({
          name            = string
          title           = string
          lifecycle_stage = string
          timeouts = optional(object({
            create = optional(string)
            read   = optional(string)
            update = optional(string)
            delete = optional(string)
          }))
          definitions = optional(map(object({
            name        = string
            title       = string
            description = optional(string)
            specification = optional(object({
              format  = optional(string, "inline")
              name    = optional(string)
              version = optional(string)
              value   = string
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
          })), {})
        })), {})
        deployments = optional(map(object({
          name           = string
          title          = optional(string)
          description    = optional(string)
          environment_id = optional(string)
          environment = optional(object({
            id  = optional(string)
            key = optional(string)
          }))
          definition_id = optional(string)
          definition = optional(object({
            id          = optional(string)
            version_key = optional(string)
            key         = optional(string)
          }))
          state = optional(string)
          server = optional(object({
            runtime_uris = list(string)
          }))
          custom_properties = optional(map(string))
          timeouts = optional(object({
            create = optional(string)
            read   = optional(string)
            update = optional(string)
            delete = optional(string)
          }))
        })), {})
      })), {})
    })), {})
    metadata_schemas = optional(map(object({
      name   = string
      schema = string
      assigned_to = optional(list(object({
        entity     = optional(string)
        required   = optional(bool)
        deprecated = optional(bool)
      })), [])
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
  })

  validation {
    condition = (
      try(var.settings.service_id, null) != null ||
      try(var.settings.service.id, null) != null ||
      try(var.settings.service.key, null) != null ||
      try(var.settings.name, null) != null
    )
    error_message = "Configure a service name, or select an existing service with service_id/service.id/service.key."
  }

  validation {
    condition     = try(var.settings.create_service, null) != true || var.settings.name != null
    error_message = "A service name is required when create_service is explicitly enabled."
  }

  validation {
    condition     = try(var.settings.api_version, "2024-03-01") == "2024-03-01"
    error_message = "Only the stable Microsoft.ApiCenter 2024-03-01 API version is supported by this module."
  }

  validation {
    condition = try(
      contains(
        ["SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned"],
        var.settings.identity.type
      ),
      true
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned,UserAssigned."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for api in values(workspace.apis) :
        alltrue([
          for version in values(api.versions) :
          contains(["design", "development", "testing", "preview", "production", "deprecated", "retired"], version.lifecycle_stage)
        ])
      ])
    ])
    error_message = "version.lifecycle_stage must be design, development, testing, preview, production, deprecated, or retired."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for environment in values(workspace.environments) :
        contains(["development", "testing", "staging", "production"], environment.kind)
      ])
    ])
    error_message = "environment.kind must be development, testing, staging, or production."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for api in values(workspace.apis) :
        contains(["rest", "graphql", "grpc", "soap", "webhook", "websocket"], api.kind)
      ])
    ])
    error_message = "api.kind must be rest, graphql, grpc, soap, webhook, or websocket."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for environment in values(workspace.environments) :
        try(contains([
          "Azure API Management",
          "Azure compute service",
          "Apigee API Management",
          "AWS API Gateway",
          "Kong API Gateway",
          "Kubernetes",
          "MuleSoft API Management"
        ], environment.server.type), true)
      ])
    ])
    error_message = "environment.server.type must be a value supported by Microsoft.ApiCenter 2024-03-01."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for environment in values(workspace.environments) :
        (
          try(environment.server.management_portal_uris == null ? true : length(environment.server.management_portal_uris) <= 1, true) &&
          try(environment.onboarding.developer_portal_uris == null ? true : length(environment.onboarding.developer_portal_uris) <= 1, true)
        )
      ])
    ])
    error_message = "Portal URI lists support at most one management and one developer portal URI in Microsoft.ApiCenter 2024-03-01."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for api in values(workspace.apis) :
        alltrue([
          for version in values(api.versions) :
          alltrue([
            for definition in values(version.definitions) :
            try(contains(["inline", "link"], definition.specification.format), true)
          ])
        ])
      ])
    ])
    error_message = "specification.format must be inline or link."
  }

  validation {
    condition = alltrue([
      for workspace in values(var.settings.workspaces) :
      alltrue([
        for api in values(workspace.apis) :
        alltrue([
          for deployment in values(api.deployments) :
          try(contains(["active", "inactive"], deployment.state), true)
        ])
      ])
    ])
    error_message = "deployment.state must be active or inactive."
  }

  validation {
    condition = alltrue([
      for metadata_schema in values(var.settings.metadata_schemas) :
      alltrue([
        for assignment in metadata_schema.assigned_to :
        try(contains(["api", "environment", "deployment"], assignment.entity), true)
      ])
    ])
    error_message = "metadata_schemas.assigned_to.entity must be api, environment, or deployment."
  }
}

variable "remote_objects" {
  description = "Combined resource groups, API Centers, and managed identities."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited by the API Center service."
  type        = map(any)
  default     = {}
}
