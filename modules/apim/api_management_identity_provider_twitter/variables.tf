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

Enable Twitter sign-in for the API Management developer portal with an existing
Twitter application configured for the portal callback. Required fields have no
module default; optional parent selectors default to null unless stated. The
provider has a fixed Azure identifier and is not named by CAF.

Value types: parent selectors and timeouts are objects; all leaf fields are strings.

- settings.api_key (required): Application consumer API key issued by Twitter.
  This is a credential, not an Azure API key or an APIM subscription key.
- settings.api_secret_key (required): Consumer API secret paired with api_key.
  Inject both credentials securely and protect Terraform state containing them.

- settings.api_management_name (optional): Explicit APIM service name, ahead of
  api_management.name and remote key lookup.
- settings.api_management (optional): Select the service receiving Twitter sign-in.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management,
  needed for lookup when no direct service name is supplied.
- settings.api_management.lz_key (optional): Service lookup landing zone;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Direct group containing the service,
  ahead of resource_group.name, its key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the service's resource group.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  the selected APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of service lookup.
  Both parent names must resolve; changing either parent recreates this provider.

- settings.timeouts (optional): Duration-string operation wait limits. Omitted/null
  emits no block and leaves provider defaults in control. For a supplied object,
  omitted/null members use the module defaults below, matching provider limits;
  these limits do not configure Twitter sign-in sessions.
- settings.timeouts.create (optional, default 30m): Wait to configure Twitter sign-in.
- settings.timeouts.read (optional, default 5m): Wait to retrieve provider settings.
- settings.timeouts.update (optional, default 30m): Wait to change the consumer credentials.
- settings.timeouts.delete (optional, default 30m): Wait to remove this identity provider.
DESCRIPTION
  type = object({
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
  })
}
