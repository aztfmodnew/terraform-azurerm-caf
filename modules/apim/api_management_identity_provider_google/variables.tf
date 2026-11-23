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

Enable Google sign-in for the API Management developer portal with an existing
Google OAuth application. Configure its consent screen and portal redirect URI
outside this module. Required fields have no module default; optional parent
selectors default to null unless stated. APIM's fixed Google identifier is not
processed by CAF naming.

Value types: parent selectors and timeouts are objects; all leaf fields are strings.

- settings.client_id (required): Google OAuth client identifier for portal sign-in,
  normally an apps.googleusercontent.com identifier rather than an Azure client ID.
- settings.client_secret (required): Secret for that Google OAuth client; inject
  through secure input and protect Terraform state containing the credential.

- settings.api_management_name (optional): Explicit service name, ahead of
  api_management.name and remote key lookup.
- settings.api_management (optional): Select the APIM service receiving Google sign-in.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management,
  needed when neither direct parent service name is supplied.
- settings.api_management.lz_key (optional): Service lookup landing zone;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Direct service resource group name,
  ahead of resource_group.name, its key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the resource group containing APIM.
- settings.resource_group.name (optional): Direct group name used ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  the selected APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of service lookup.
  Both parent names must resolve; changing a parent recreates this provider resource.

- settings.timeouts (optional): Duration-string operation wait limits, not Google
  sign-in session limits. Omitted/null emits no block and keeps provider defaults.
  In a supplied object, omitted/null members use the module defaults below, matching
  the provider's documented operation limits.
- settings.timeouts.create (optional, default 30m): Wait to configure Google sign-in.
- settings.timeouts.read (optional, default 5m): Wait to retrieve provider settings.
- settings.timeouts.update (optional, default 30m): Wait to update the OAuth client settings.
- settings.timeouts.delete (optional, default 30m): Wait to remove the Google provider.
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
