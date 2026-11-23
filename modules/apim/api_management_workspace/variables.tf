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

Create a workspace that groups APIs and related resources for a team within an
API Management service. The parent must support workspaces; Classic Premium is
the documented parent tier. Required fields have no module default. Optional
fields default to null and defer to provider/API behavior unless stated.

Value types: api_management and timeouts are objects; all leaf fields are strings.

- settings.name (required): Logical workspace name processed by CAF naming and
  global naming controls. The workspace naming definition permits compatible
  alphanumeric/hyphen child names up to 80 characters. Renaming recreates it.
- settings.display_name (required): Friendly team/workspace label shown in APIM.
- settings.description (optional): Explanation of the team's workspace purpose or ownership.
- settings.api_management_id (optional): Direct parent service ARM ID, ahead of
  api_management.id and key lookup. A service name alone is not an ARM ID.
- settings.api_management (optional): Select the APIM service hosting the workspace.
- settings.api_management.id (optional): Direct service ARM ID when the top-level
  api_management_id is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management,
  needed for lookup when neither direct service ID is supplied.
- settings.api_management.lz_key (optional): Landing zone containing that service
  key; omitted/null uses client_config.landingzone_key.
  A parent ID must resolve; moving the workspace to another parent recreates it.

- settings.timeouts (optional): Maximum operation waits as duration strings.
  Omitted/null emits no block, retaining provider defaults. Within a supplied
  object, omitted/null members use the module defaults below, matching documented
  provider limits; these are not API request or workspace gateway timeouts.
- settings.timeouts.create (optional, default 30m): Wait limit to create the workspace.
- settings.timeouts.read (optional, default 5m): Wait limit to retrieve the workspace.
- settings.timeouts.update (optional, default 30m): Wait limit to change workspace metadata.
- settings.timeouts.delete (optional, default 30m): Wait limit to remove the workspace.
DESCRIPTION
  type = object({
    name              = string
    display_name      = string
    description       = optional(string)
    api_management_id = optional(string)
    api_management = optional(object({
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
