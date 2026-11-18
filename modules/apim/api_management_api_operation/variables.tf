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
Describe an individual HTTP operation within the separately supplied API.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- operation_id (required string): stable logical operation identifier within the
  API, not an ARM resource ID.
- display_name (required string): human-readable operation label.
- method (required string): non-empty uppercase HTTP method such as GET, POST,
  PUT, PATCH, DELETE, HEAD, OPTIONS, or TRACE.
- url_template (required string): relative operation URL, optionally containing
  named parameters described by template_parameters.
- description (optional string): explanatory operation documentation.
- request (optional object): accepted request definition. description is optional
  request documentation; headers is a map of request-header parameter objects;
  query_parameters is a map of query-string parameter objects; representations
  is a map of supported request-body representations.
- responses (optional map of objects): possible operation responses, keyed by
  caller-chosen stable labels. Each object requires status_code (HTTP response
  code); optional description documents that response; optional headers is a
  map of response-header parameters; optional representations is a map of
  response-body representations.
- template_parameters (optional map): URL-template parameters, using the common
  parameter structure below. Define them for placeholders in url_template.

Common parameter structure applies identically to request.headers,
request.query_parameters, responses.*.headers, template_parameters, and the
form_parameters maps within any request/response representation:
- name (required string): actual header, query, template, or form field name.
- required (required bool): whether callers must provide this parameter.
- type (required string): parameter data type understood by APIM.
- description (optional string): parameter documentation.
- default_value (optional string): parameter value when none is supplied.
- values (optional set of strings): allowed parameter values.
- schema_id (optional string): logical APIM schema identifier for the parameter.
- type_name (optional string): type within that schema.
- examples (optional map of objects): named examples using the common example
  structure below.

Common representation structure applies to request.representations and
responses.*.representations:
- content_type (required string): body MIME type.
- schema_id (optional string): logical APIM schema identifier for the body.
- type_name (optional string): type defined within that schema.
- form_parameters (optional map): form fields using the common parameter
  structure, required by the provider for application/x-www-form-urlencoded
  and multipart/form-data. Those content types cannot use schema_id/type_name.
- examples (optional map): body examples using the common example structure.

Common example structure applies to every examples map at every level:
- name (required string): example identifier, independent of the map key.
- summary (optional string): short example label.
- description (optional string): explanatory example documentation.
- value (optional string): inline example content.
- external_value (optional string): URL of externally hosted example content.

All parameter/representation/example maps, responses, and template_parameters
default to {} for omission/null; request itself defaults to null. Other optional
fields default to null. Schema IDs and type names are passed directly, with no
CAF schema lookup.

- api_management / api / resource_group (optional objects): root parent-name
  references. Their fields are optional/null: name is a direct name preferred
  over key, key selects the corresponding combined CAF collection, and lz_key
  selects its zone (current by default). resource_group_name is a legacy direct
  fallback after resource_group.name; resource_group_key is the legacy group key
  preferred before resource_group.key. api_management_name and api_name inside
  settings are compatibility metadata, not read by this child or the root
  parent-name lookups; use the separate module inputs when calling directly.
- timeouts (optional object): create limits operation creation, read retrieval,
  update definition changes, and delete removal. Every field is an optional
  duration string; null preserves its provider timeout.
Undeclared attributes are discarded by the settings object type.
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

  validation {
    condition     = can(regex("^[A-Z]+$", var.settings.method))
    error_message = "settings.method must be a non-empty uppercase HTTP method such as GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS or TRACE."
  }
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
