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

Group versions of an API inside an APIM workspace and choose where requests carry
the requested API version. Required fields have no module default. Optional
fields default to null and defer to provider/API behavior unless stated.

Value types: api_management_workspace and timeouts are objects; all leaf fields
are strings.

- settings.name (required): Logical version-set name processed by CAF naming.
  The module uses the compatible service-level APIM API version set definition
  for alphanumeric/hyphen child names up to 80 characters because no workspace-child
  naming definition exists. Global naming controls apply; renaming recreates it.
- settings.display_name (required): Friendly name identifying this family of API versions.
- settings.versioning_scheme (required): Where the gateway reads the version:
  Header from a request header, Query from a query parameter, or Segment from the
  URL path. These three case-sensitive values are the supported choices.
- settings.description (optional): Human-readable explanation of the version family.
- settings.version_header_name (optional): Request header carrying the version
  when using Header, for example api-version; leave null for other schemes.
- settings.version_query_name (optional): Query-string parameter carrying the version
  when using Query, for example api-version; leave null for other schemes.
- settings.api_management_workspace_id (optional): Direct parent workspace ARM ID;
  takes precedence over api_management_workspace.id and key lookup.
- settings.api_management_workspace (optional): Select the workspace owning the version set.
- settings.api_management_workspace.id (optional): Direct workspace ARM ID when
  the top-level ID is absent; takes precedence over key.
- settings.api_management_workspace.key (optional): Key in
  remote_objects.api_management_workspace, required for lookup without a direct ID.
- settings.api_management_workspace.lz_key (optional): Landing zone containing that
  workspace key; omitted/null uses client_config.landingzone_key.
  A workspace ID must resolve; moving to another workspace recreates the version set.

- settings.timeouts (optional): Infrastructure-operation wait limits as duration
  strings, not API-request timeouts. Omitted/null emits no block and retains provider
  defaults. In a supplied object, omitted/null members use the module defaults
  below, matching the provider's documented operation limits.
- settings.timeouts.create (optional, default 30m): Wait limit to create the version set.
- settings.timeouts.read (optional, default 5m): Wait limit to retrieve version-set settings.
- settings.timeouts.update (optional, default 30m): Wait limit to change versioning settings.
- settings.timeouts.delete (optional, default 30m): Wait limit to remove the version set.
DESCRIPTION
  type = object({
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
  })
}
