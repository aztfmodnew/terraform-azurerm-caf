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

Store a reusable XML policy fragment within an API Management workspace.
Creating a fragment does not apply it automatically; policies must include its
resolved resource name with include-fragment. Required fields have no module
default; optional fields default to null unless a module default is stated.

Value types: api_management_workspace and timeouts are objects; all leaf fields
are strings, including inline XML and operation durations.

- settings.name (required): Logical fragment resource name processed by CAF using
  the compatible service-level APIM policy fragment definition because no workspace
  child definition exists. Global naming controls apply to this alphanumeric/hyphen
  child name, up to 80 characters. Renaming recreates the fragment.
- settings.xml_content (required): Fragment XML text, normally enclosed in a fragment
  element, to reuse in policies. Supply content rather than a file path; avoid
  embedding credentials.
- settings.xml_format (optional, module default xml including explicit null):
  Content format, either xml or rawxml. Choose rawxml when unescaped policy
  expressions require it. Azure imports fragments as xml; change afterward if needed.
- settings.description (optional): Human-readable explanation of the fragment's purpose.
- settings.api_management_workspace_id (optional): Direct workspace ARM ID, ahead
  of api_management_workspace.id and remote key lookup.
- settings.api_management_workspace (optional): Select the workspace owning the fragment.
- settings.api_management_workspace.id (optional): Direct workspace ARM ID when
  the top-level ID is absent; takes precedence over key.
- settings.api_management_workspace.key (optional): Key in
  remote_objects.api_management_workspace, needed when neither direct ID is supplied.
- settings.api_management_workspace.lz_key (optional): Landing zone containing that
  workspace key; omitted/null uses client_config.landingzone_key.
  A workspace ID must resolve; moving to another workspace recreates the fragment.

- settings.timeouts (optional): Maximum infrastructure-operation waits as duration
  strings, not policy execution limits. Omitted/null emits no block and retains
  provider defaults. In a supplied object, omitted/null members use the module
  defaults below, matching the provider's documented operation limits.
- settings.timeouts.create (optional, default 30m): Wait to create the reusable fragment.
- settings.timeouts.read (optional, default 5m): Wait to retrieve the fragment.
- settings.timeouts.update (optional, default 30m): Wait to change fragment XML or metadata.
- settings.timeouts.delete (optional, default 30m): Wait to remove the fragment.
DESCRIPTION
  type = object({
    name                        = string
    xml_content                 = string
    xml_format                  = optional(string, "xml")
    description                 = optional(string)
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
