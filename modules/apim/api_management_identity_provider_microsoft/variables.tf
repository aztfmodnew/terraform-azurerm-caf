variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
  default     = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
  default     = {}
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "settings" {
  description = <<DESCRIPTION
Undeclared attributes are ignored by Terraform's object type conversion.

Configure Microsoft sign-in for the API Management developer portal with an
existing application registration and its registered portal redirect URI.
Required fields have no module default. Optional parent selectors default to null
unless stated. This provider uses APIM's fixed identifier, not CAF naming.

Value types: parent selectors and timeouts are objects; all leaf fields are strings.

- settings.client_id (required): Client/application identifier of the registration
  used for Microsoft sign-in; use an application configured for the intended audience.
- settings.client_secret (required): Secret issued for that application registration.
  Supply it securely and protect Terraform state containing the credential.

- settings.api_management_name (optional): Explicit parent service name; wins over
  api_management.name and remote key lookup.
- settings.api_management (optional): Select the APIM service receiving this provider.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Service key in remote_objects.api_management,
  needed for lookup when neither direct service name is supplied.
- settings.api_management.lz_key (optional): Landing zone containing that service key;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Direct service resource group name,
  ahead of resource_group.name, its key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the group containing the APIM service.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  the resolved APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of service lookup.
  Both parent names must resolve; changing a parent recreates the provider resource.

- settings.timeouts (optional): Infrastructure-operation duration-string wait limits,
  not token/session lifetimes. Omitted/null emits no block, retaining provider
  defaults. In a supplied object, omitted/null members use the module defaults
  below, matching the provider's documented operation limits.
- settings.timeouts.create (optional, default 30m): Wait to configure Microsoft sign-in.
- settings.timeouts.read (optional, default 5m): Wait to retrieve provider configuration.
- settings.timeouts.update (optional, default 30m): Wait to change client settings.
- settings.timeouts.delete (optional, default 30m): Wait to remove this sign-in provider.
DESCRIPTION
  type = object({
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
  })
}
