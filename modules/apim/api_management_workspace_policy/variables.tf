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

Configure the singleton policy document for an API Management workspace.
All settings fields are optional at the type level and default to null, but
exactly one policy source and a resolvable workspace ID are required. No CAF name
is generated for this singleton. Avoid credentials in XML; reference secret named
values where needed.

Value types: api_management_workspace and timeouts are objects; all leaf fields
are strings, including inline XML and operation durations.

- settings.xml_content (optional): Complete policy XML supplied inline, including
  the policies element and applicable inbound/backend/outbound/on-error sections.
  Mutually exclusive with xml_link; preserve base elements where parent policy
  inheritance is intended. This is XML text, not a local file path.
- settings.xml_link (optional): Publicly accessible URL of a policy XML document
  for Azure to retrieve. Mutually exclusive with xml_content; a private local path
  is not a URL. For this source the provider may compute xml_content after retrieval,
  so omitted inline input does not guarantee a null resource attribute during plan.
- settings.api_management_workspace_id (optional): Direct parent workspace ARM ID;
  takes precedence over api_management_workspace.id and key lookup.
- settings.api_management_workspace (optional): Select the workspace whose policy
  will be configured; the policy applies to that workspace rather than the whole service.
- settings.api_management_workspace.id (optional): Direct workspace ARM ID when
  the top-level ID is absent; takes precedence over key.
- settings.api_management_workspace.key (optional): Key in
  remote_objects.api_management_workspace, needed when neither direct ID is supplied.
- settings.api_management_workspace.lz_key (optional): Landing zone containing the
  workspace key; omitted/null uses client_config.landingzone_key.
  Moving to another workspace recreates the policy resource.

- settings.timeouts (optional): Infrastructure-operation duration-string wait limits,
  not gateway request/policy execution limits. Omitted/null emits no block and uses
  provider defaults. In a supplied object, omitted/null members use the module
  defaults below, matching the provider's documented limits.
- settings.timeouts.create (optional, default 30m): Wait to configure the workspace policy.
- settings.timeouts.read (optional, default 5m): Wait to retrieve the policy.
- settings.timeouts.update (optional, default 30m): Wait to change the policy document.
- settings.timeouts.delete (optional, default 30m): Wait to remove the policy resource.
DESCRIPTION
  type = object({
    xml_content                 = optional(string)
    xml_link                    = optional(string)
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
  validation {
    condition     = (var.settings.xml_content != null) != (var.settings.xml_link != null)
    error_message = "Specify exactly one of xml_content or xml_link."
  }
}
