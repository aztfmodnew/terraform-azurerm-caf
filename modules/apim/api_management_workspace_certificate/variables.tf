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

Add a certificate to an APIM workspace from inline PKCS#12 data or a Key Vault
secret. Required fields have no module default; optional fields default to null
unless stated. Choose exactly one source category: inline data OR a Key Vault
source. APIM's selected identity must already have access to the vault; this
module neither attaches identities nor grants vault permissions.

Value types: certificate/vault/identity/workspace selectors and timeouts are
objects; all leaf fields are strings, including base64 certificate content.

- settings.name (required): Logical certificate name processed by CAF. The module
  uses the compatible service-level APIM certificate naming definition because no
  workspace-child definition exists; global naming options apply. The definition
  uses alphanumeric/hyphen child names up to 80 characters; renaming recreates it.
- settings.certificate_data_base64 (optional): Base64-encoded PKCS#12 (.pfx) bytes,
  not a file path or PEM text. Supply this or a Key Vault source, never both.
- settings.password (optional): Password protecting the inline PFX. Requires
  certificate_data_base64; leave null if the PFX needs no password. Inject private
  bytes/passwords securely and protect Terraform state.
- settings.key_vault_secret_id (optional): Direct URI of the Key Vault secret
  holding the certificate, not a certificate ARM ID. Takes precedence over all
  Key Vault reference helpers; it cannot be combined with inline data.
- settings.key_vault_secret (optional): Resolve a managed certificate's backing
  secret URI. When present, choose exactly one of certificate_key and
  certificate_request_key, even if an explicit secret URI takes precedence.
- settings.key_vault_secret.certificate_key (optional): Key in
  remote_objects.keyvault_certificates; the selected output's secret_id is used,
  not its certificate id. Mutually exclusive with certificate_request_key.
- settings.key_vault_secret.certificate_request_key (optional): Key in
  remote_objects.keyvault_certificate_requests for a generated certificate's
  secret_id. Mutually exclusive with certificate_key.
- settings.key_vault_secret.lz_key (optional): Landing zone for either certificate
  collection lookup; omitted/null uses client_config.landingzone_key.
- settings.secret_name (optional): Secret name used with key_vault to construct
  a versionless vault_uri/secrets/secret_name URI. Required for that helper only.
- settings.key_vault (optional): Vault reference used with secret_name as the final
  source fallback after direct URI and managed-certificate secret references.
- settings.key_vault.key (required when key_vault is supplied): Key in
  remote_objects.keyvaults whose vault_uri supplies the vault endpoint.
- settings.key_vault.lz_key (optional): Vault lookup landing zone;
  omitted/null uses client_config.landingzone_key.
- settings.user_assigned_identity_client_id (optional): Direct client ID of the
  APIM user-assigned identity authorized to read the secret. Wins over
  managed_identity lookup; only permitted with a Key Vault certificate source.
- settings.managed_identity (optional): Reference resolving that user-assigned
  identity's client ID, not its ARM/principal ID; requires a Key Vault source.
  With neither identity selector, null is forwarded and APIM uses its system identity.
- settings.managed_identity.key (required when managed_identity is supplied): Key
  in remote_objects.managed_identities whose client_id is used.
- settings.managed_identity.lz_key (optional): Identity lookup landing zone;
  omitted/null uses client_config.landingzone_key.

- settings.api_management_workspace_id (optional): Direct parent workspace ARM ID;
  takes precedence over api_management_workspace.id and remote key lookup.
- settings.api_management_workspace (optional): Select the workspace receiving the certificate.
- settings.api_management_workspace.id (optional): Direct workspace ARM ID when
  the top-level ID is absent; takes precedence over key.
- settings.api_management_workspace.key (optional): Key in
  remote_objects.api_management_workspace, needed when neither direct ID is supplied.
- settings.api_management_workspace.lz_key (optional): Workspace lookup landing
  zone; omitted/null uses client_config.landingzone_key.
  A workspace ID must resolve; moving the certificate to another workspace recreates it.

- settings.timeouts (optional): Duration-string infrastructure-operation wait limits.
  Omitted/null emits no block and retains provider defaults. In a supplied object,
  omitted/null members use the module defaults below, matching provider limits.
  These limits do not set certificate expiration, renewal or vault secret lifetime.
- settings.timeouts.create (optional, default 30m): Wait to add the workspace certificate.
- settings.timeouts.read (optional, default 5m): Wait to retrieve certificate metadata.
- settings.timeouts.update (optional, default 30m): Wait to update the certificate source.
- settings.timeouts.delete (optional, default 30m): Wait to remove the certificate from APIM.
DESCRIPTION
  type = object({
    name                    = string
    certificate_data_base64 = optional(string)
    password                = optional(string)
    key_vault_secret_id     = optional(string)
    key_vault_secret = optional(object({
      certificate_key         = optional(string)
      certificate_request_key = optional(string)
      lz_key                  = optional(string)
    }))
    user_assigned_identity_client_id = optional(string)
    secret_name                      = optional(string)
    key_vault = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    managed_identity = optional(object({
      key    = string
      lz_key = optional(string)
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
    condition = (var.settings.certificate_data_base64 != null) != (
      var.settings.key_vault_secret_id != null || var.settings.key_vault_secret != null || (var.settings.key_vault != null && var.settings.secret_name != null)
    )
    error_message = "Specify exactly one certificate source: certificate_data_base64 or a Key Vault secret URI/reference."
  }
  validation {
    condition = var.settings.key_vault_secret == null || (
      (try(var.settings.key_vault_secret.certificate_key, null) != null) !=
      (try(var.settings.key_vault_secret.certificate_request_key, null) != null)
    )
    error_message = "key_vault_secret requires exactly one of certificate_key or certificate_request_key."
  }
  validation {
    condition     = var.settings.password == null || var.settings.certificate_data_base64 != null
    error_message = "password requires certificate_data_base64."
  }
  validation {
    condition     = (var.settings.user_assigned_identity_client_id == null && var.settings.managed_identity == null) || var.settings.certificate_data_base64 == null
    error_message = "User-assigned identity selection requires a Key Vault certificate source."
  }
}
