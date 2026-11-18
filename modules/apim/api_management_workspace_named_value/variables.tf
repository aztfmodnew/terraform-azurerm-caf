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

Create a reusable workspace named value for APIM policy expressions, from a
literal value or a Key Vault secret. Required fields have no module default.
Optional fields default to null and defer to provider/API behavior unless stated.
Specify exactly one of value and value_from_key_vault; a Key Vault source also
requires secret = true. Vault permissions and APIM identity attachment are
prerequisites, not created by this module.

Value types: workspace/vault/identity/source selectors and timeouts are objects.
secret is a boolean, tags is a list of strings, and all other leaf fields are strings.

- settings.name (required): Logical resource name processed by CAF using the
  compatible service-level APIM named value definition because no workspace-child
  definition exists. Global naming controls apply to this alphanumeric/hyphen
  child name, up to 80 characters, not to the policy display name.
- settings.display_name (required): Stable identifier used inside policy
  {{named-value}} expressions; passed through unchanged rather than CAF-renamed.
- settings.secret (optional, module default false including explicit null):
  Whether Azure treats/encrypts this as a secret named value. Set true for a vault
  reference or a sensitive literal; this flag does not prevent values entering state.
- settings.tags (optional): List of APIM labels for organizing the named value,
  not an Azure resource tag map. Null leaves labels unspecified; no base tags merge.
- settings.value (optional): Literal policy value, such as a backend URL, or a policy
  expression. Mutually exclusive with value_from_key_vault; inject sensitive
  literals securely and protect Terraform state.
- settings.value_from_key_vault (optional): Singleton vault source, mutually exclusive
  with value and requiring secret = true. Choose a direct secret URI or the
  key_vault plus secret_name helper below.
- settings.value_from_key_vault.secret_id (optional module selector): Direct Key
  Vault secret URI, not a vault/certificate ARM ID. Takes precedence over the vault
  helper; a URI must resolve because it is required in the emitted provider block.
- settings.value_from_key_vault.secret_name (optional): Secret name appended to the
  referenced vault endpoint; required when the vault helper supplies the URI.
- settings.value_from_key_vault.key_vault (optional): Vault reference used with
  secret_name only when no direct secret_id is supplied.
- settings.value_from_key_vault.key_vault.key (required when key_vault is supplied):
  Key in remote_objects.keyvaults whose vault_uri constructs a versionless
  vault_uri/secrets/secret_name URI.
- settings.value_from_key_vault.key_vault.lz_key (optional): Vault lookup landing
  zone; omitted/null uses client_config.landingzone_key.
- settings.value_from_key_vault.identity_client_id (optional): Direct client ID of
  an APIM user-assigned identity authorized to read the secret; wins over identity
  lookup. Without either selector null is forwarded and APIM uses its system identity.
- settings.value_from_key_vault.managed_identity (optional): Resolve a user-assigned
  identity's client ID instead of providing it directly.
- settings.value_from_key_vault.managed_identity.key (required when managed_identity
  is supplied): Key in remote_objects.managed_identities whose client_id is used,
  not its ARM or principal ID.
- settings.value_from_key_vault.managed_identity.lz_key (optional): Identity lookup
  landing zone; omitted/null uses client_config.landingzone_key.

- settings.api_management_workspace_id (optional): Direct workspace ARM ID, ahead
  of api_management_workspace.id and key lookup.
- settings.api_management_workspace (optional): Select the workspace owning the named value.
- settings.api_management_workspace.id (optional): Direct workspace ARM ID when
  the top-level ID is absent; takes precedence over key.
- settings.api_management_workspace.key (optional): Key in
  remote_objects.api_management_workspace, needed when neither direct ID is supplied.
- settings.api_management_workspace.lz_key (optional): Workspace lookup landing
  zone; omitted/null uses client_config.landingzone_key.
  A workspace ID must resolve; changing the workspace or resource name recreates it.

- settings.timeouts (optional): Duration-string infrastructure-operation wait limits.
  Omitted/null emits no block and retains provider defaults. In a supplied object,
  omitted/null members use the module defaults below, matching provider limits.
  These are not policy execution or vault secret rotation intervals.
- settings.timeouts.create (optional, default 30m): Wait to create the named value.
- settings.timeouts.read (optional, default 5m): Wait to retrieve the named value.
- settings.timeouts.update (optional, default 30m): Wait to change its source or metadata.
- settings.timeouts.delete (optional, default 30m): Wait to remove the named value.
DESCRIPTION
  type = object({
    name         = string
    display_name = string
    secret       = optional(bool, false)
    tags         = optional(list(string))
    value        = optional(string)
    value_from_key_vault = optional(object({
      secret_id          = optional(string)
      identity_client_id = optional(string)
      secret_name        = optional(string)
      key_vault = optional(object({
        key    = string
        lz_key = optional(string)
      }))
      managed_identity = optional(object({
        key    = string
        lz_key = optional(string)
      }))
    }))
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
    condition     = (var.settings.value != null) != (var.settings.value_from_key_vault != null)
    error_message = "Specify exactly one of value or value_from_key_vault."
  }
  validation {
    condition     = var.settings.value_from_key_vault == null || var.settings.secret
    error_message = "A Key Vault backed named value requires secret = true."
  }
  validation {
    condition = var.settings.value_from_key_vault == null || (
      try(var.settings.value_from_key_vault.secret_id, null) != null ||
      (try(var.settings.value_from_key_vault.key_vault, null) != null && try(var.settings.value_from_key_vault.secret_name, null) != null)
    )
    error_message = "value_from_key_vault requires secret_id or both key_vault and secret_name."
  }
}
