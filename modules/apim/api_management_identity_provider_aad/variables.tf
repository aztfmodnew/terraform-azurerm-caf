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

Enable Microsoft Entra ID authentication for the API Management developer portal
using an existing application registration. Required fields have no module default;
optional fields default to null and defer to provider/API behavior unless stated.
The identity provider's Azure identifier is fixed; CAF naming is not applied.

Value types: parent selectors and timeouts are objects; allowed_tenants is a list
of strings. All remaining leaf fields are strings.

- settings.client_id (required): Application/client identifier of the Entra
  registration configured for developer portal sign-in.
- settings.client_secret (required): Secret issued for that registration. Supply
  securely, configure the portal redirect URI, and protect Terraform state.
- settings.allowed_tenants (required): Tenant identifiers whose users may sign in;
  this is the allow-list, not a list of application IDs.
- settings.client_library (optional): Authentication client library used by the
  developer portal, for example MSAL-2. Null leaves library selection to the provider/API.
- settings.signin_tenant (optional): Tenant UUID used for sign-in instead of the
  common endpoint. Supply a UUID, not an onmicrosoft.com domain; null does not force
  a tenant-specific endpoint.

- settings.api_management_name (optional): Explicit parent APIM service name;
  takes precedence over api_management.name and key lookup.
- settings.api_management (optional): Select the service receiving this sign-in provider.
- settings.api_management.name (optional): Direct parent name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Service key in remote_objects.api_management,
  needed when neither direct name is supplied.
- settings.api_management.lz_key (optional): Service lookup landing zone;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Explicit group containing the service;
  wins over resource_group.name, its key lookup and the APIM-output fallback.
- settings.resource_group (optional): Select the service's resource group.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  the resolved APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone; omitted/null
  uses client_config.landingzone_key independently of the APIM reference.
  Both parent names must resolve. Moving the provider to another parent recreates it.

- settings.timeouts (optional): Duration-string operation wait limits. Omitted/null
  omits the block, retaining provider defaults. Within a supplied object,
  omitted/null members use the module defaults below, matching documented provider
  limits; these do not control user sign-in session lifetime.
- settings.timeouts.create (optional, default 30m): Wait limit to configure the provider.
- settings.timeouts.read (optional, default 5m): Wait limit to retrieve its configuration.
- settings.timeouts.update (optional, default 30m): Wait limit to change sign-in settings.
- settings.timeouts.delete (optional, default 30m): Wait limit to remove the provider.
DESCRIPTION
  type = object({
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
  })
}
