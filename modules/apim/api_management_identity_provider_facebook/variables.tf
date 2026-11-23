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

Enable Facebook sign-in for the API Management developer portal using an existing
Facebook application. The external application and redirect registration must
already exist. Required fields have no module default; optional selectors default
to null unless stated. The provider has a fixed Azure identifier, with no CAF name.

Value types: parent selectors and timeouts are objects; all leaf fields are strings.

- settings.app_id (required): Facebook application identifier used by portal sign-in.
- settings.app_secret (required): Secret issued for that Facebook application.
  Inject securely and protect Terraform state; this is not an Azure application secret.

- settings.api_management_name (optional): Explicit APIM service name; wins over
  api_management.name and key lookup.
- settings.api_management (optional): Select the APIM service to configure.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Service key in remote_objects.api_management,
  required for lookup when no direct service name is supplied.
- settings.api_management.lz_key (optional): Landing zone containing that key;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Direct service resource group name,
  ahead of resource_group.name, its key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the resource group containing APIM.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Group key in remote_objects.resource_groups;
  the resolved APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of APIM lookup.
  Both parent names must resolve; changing either parent recreates the provider.

- settings.timeouts (optional): Duration-string infrastructure wait limits.
  Omitted/null emits no block, preserving provider defaults. In a supplied object,
  omitted/null members use the module defaults below, matching provider limits.
  These are not user login/session timeout settings.
- settings.timeouts.create (optional, default 30m): Wait to configure Facebook sign-in.
- settings.timeouts.read (optional, default 5m): Wait to retrieve provider settings.
- settings.timeouts.update (optional, default 30m): Wait to change application credentials.
- settings.timeouts.delete (optional, default 30m): Wait to remove this identity provider.
DESCRIPTION
  type = object({
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
  })
}
