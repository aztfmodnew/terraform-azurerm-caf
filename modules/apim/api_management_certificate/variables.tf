variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
Make a client-authentication certificate available inside API Management.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): certificate resource name processed by CAF naming.
- data (optional sensitive string): base64-encoded PFX certificate bytes.
- password (optional sensitive string): password protecting inline PFX data.
- key_vault_secret_id (optional string): Key Vault secret URI containing a
  PKCS#12 certificate; a secret identifier, not the vault ARM ID.
- key_vault_id (optional string): legacy spelling of key_vault_secret_id with
  exactly the same secret-URI meaning.
- key_vault_secret (optional object): resolve an existing managed certificate's
  backing secret. Optional certificate_key selects
  remote_objects.keyvault_certificates[lz_key][certificate_key].secret_id;
  optional certificate_request_key selects the corresponding
  keyvault_certificate_requests collection. Set exactly one of these keys.
  Optional lz_key selects its landing zone and defaults to
  client_config.landingzone_key when omitted/null.
  Exactly one source among data, key_vault_secret_id, key_vault_id, and
  key_vault_secret must be supplied; current and legacy source fields cannot
  both be set.
- key_vault_identity_client_id (optional string): direct client ID of the
  user-assigned managed identity that retrieves the Key Vault secret.
- key_vault_identity_client (optional object): alternate identity reference.
  Optional id is a direct identity client ID despite the legacy field name;
  optional key selects remote_objects.managed_identities[lz_key][key].client_id;
  optional lz_key defaults to the current zone. Resolution prefers
  key_vault_identity_client_id, then this object's id, then its key lookup.
  The identity must have access to the secret and be assigned to APIM.
- api_management / resource_group (optional objects): root parent references;
  all nested fields are optional/null. name is a direct resource name preferred
  over key; key selects the corresponding combined CAF collection; lz_key
  selects the landing zone (current by default). id is retained metadata, not
  used for these name-based root inputs. The root supplies resolved parent
  names as separate child inputs.
- timeouts (optional object): create limits certificate registration, read
  retrieval, update replacement, and delete removal. Each field is an optional
  duration string and leaves the provider timeout unchanged when null.
All optional values default to null; this child supplies no certificate or
credential defaults. Undeclared attributes are discarded by the settings type.
  DESCRIPTION
  type = object({
    name = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    data     = optional(string)
    password = optional(string)
    key_vault_secret = optional(object({
      certificate_key         = optional(string)
      certificate_request_key = optional(string)
      lz_key                  = optional(string)
    }))
    key_vault_secret_id = optional(string)
    key_vault_id        = optional(string)
    key_vault_identity_client = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    key_vault_identity_client_id = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length([
      for present in [
        var.settings.data != null,
        var.settings.key_vault_secret != null,
        var.settings.key_vault_secret_id != null,
        var.settings.key_vault_id != null
      ] : present if present
    ]) == 1
    error_message = "Specify exactly one API Management certificate source: data, key_vault_secret, key_vault_secret_id, or key_vault_id."
  }

  validation {
    condition = var.settings.key_vault_secret == null || (
      (try(var.settings.key_vault_secret.certificate_key, null) != null) !=
      (try(var.settings.key_vault_secret.certificate_request_key, null) != null)
    )
    error_message = "When key_vault_secret is specified, set exactly one of certificate_key or certificate_request_key."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_management_name" {
  description = " The Name of the API Management Service where this Service should be created. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The Name of the Resource Group where the API Management Service exists. Changing this forces a new resource to be created."
}
