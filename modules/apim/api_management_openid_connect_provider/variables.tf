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

Register an OpenID Connect provider with API Management so clients can use an
existing identity provider's discovery metadata and application credentials.
Required fields have no module default. Optional fields default to null and defer
to provider/API behavior unless a default is stated.

Value types: parent selectors and timeouts are objects; all leaf fields are strings.

- settings.name (required): Logical provider resource name, processed through CAF
  naming and global naming controls; changing the resulting name recreates it.
- settings.display_name (required): Friendly provider label presented to API consumers.
- settings.client_id (required): Client application identifier registered with the
  external OpenID provider; not the tenant ID or the discovery URL.
- settings.client_secret (required): Secret issued for that client registration.
  Supply credentials securely and protect state; both client fields are sensitive
  in the resource schema.
- settings.metadata_endpoint (required): URI of the provider's OpenID discovery
  metadata document, typically its .well-known/openid-configuration endpoint.
- settings.description (optional): Human-readable explanation of this provider's use.

- settings.api_management_name (optional): Direct parent service name, ahead of
  api_management.name and remote key lookup.
- settings.api_management (optional): Select the APIM service receiving the provider.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management,
  needed for lookup when no direct service name is supplied.
- settings.api_management.lz_key (optional): Service lookup landing zone;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Direct group containing the service,
  ahead of resource_group.name, its key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the resource group containing APIM.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  the resolved APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of APIM lookup.
  Both parent names must resolve; changing a parent recreates the provider resource.

- settings.timeouts (optional): Duration-string infrastructure-operation wait limits,
  not authentication token lifetimes. Omitted/null emits no block and keeps provider
  defaults. In a supplied object, omitted/null members use the module defaults below,
  matching the provider's documented operation limits.
- settings.timeouts.create (optional, default 30m): Wait to create the OpenID provider.
- settings.timeouts.read (optional, default 5m): Wait to retrieve the provider settings.
- settings.timeouts.update (optional, default 30m): Wait to change metadata/client settings.
- settings.timeouts.delete (optional, default 30m): Wait to remove the provider.
DESCRIPTION
  type = object({
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
  })
}
