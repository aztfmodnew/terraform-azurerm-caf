variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings for an API Management API operation.

Required provider settings: operation_id, display_name, method, and url_template.
Optional CAF references: api_management, api_management_name, api, api_name,
resource_group, resource_group_key, and resource_group_name. Optional provider
settings: description, request, responses, template_parameters, and timeouts.

HTTP method accepts the operation method supported by API Management. Request
and response blocks support headers, query parameters, representations,
form parameters, and examples. Configure template_parameters when url_template
contains parameters. Representation form_parameters are required for
application/x-www-form-urlencoded and multipart/form-data content types;
schema_id and type_name are not valid with those content types.
DESCRIPTION
  type = object({
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
  })
}

variable "remote_objects" {
  description = "Remote objects used to resolve API Management dependencies."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "api_management_name" {
  description = "Name of the API Management Service containing the API."
  type        = string
}

variable "api_name" {
  description = "Name of the API containing the operation."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the API Management Service."
  type        = string
}
