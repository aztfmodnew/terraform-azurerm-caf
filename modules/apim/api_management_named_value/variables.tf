variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Defines a reusable APIM policy value, supplied directly or retrieved from Key
Vault. Attributes not declared in the object type are ignored by Terraform.

Value and naming:
- name (string, required): Base name passed to CAF naming for the named-value
  resource. Changing the generated name replaces the resource.
- display_name (string, required): Stable APIM policy identifier, for example
  backend-endpoint in {{backend-endpoint}}. CAF naming is not applied to it.
- value (string, optional; default null): Literal text or policy expression
  stored in APIM. Use this for a directly supplied value rather than a Key Vault
  reference. Exactly one of value or value_from_key_vault must be set. Values
  can be recorded in Terraform state; do not commit secrets.
- secret (bool, optional; default false, including explicit null): Marks the
  value as secret and encrypted in APIM. Required to be true for Key Vault
  references. This flag does not mark the Terraform input itself as sensitive.
- tags (list(string), optional; default null): APIM labels for organizing named
  values. These are not Azure resource tags and do not inherit landing-zone tags.

Parent service and resource group:
- api_management (object, optional; default null): Selects the parent service.
  Supply a name or a key reference; a parent service must resolve.
  - name (string, optional; default null): Existing APIM service name, used
    before the key-based lookup.
  - key (string, optional; default null): Business key in the api_management
    remote collection when no explicit name is supplied.
  - lz_key (string, optional; default null): Namespace for key; null selects
    client_config.landingzone_key.
- resource_group_name (string, optional; default null): Explicit name of the
  parent APIM service's resource group. Overrides all resource_group inputs.
- resource_group (object, optional; default null): Alternative resource-group
  selector. A resource group must resolve.
  - name (string, optional; default null): Explicit group name, used after
    resource_group_name and before the module-level resource_group argument.
  - key (string, optional; default null): Business key in resource_groups,
    consulted only when neither explicit nor module-level group name resolves.
  - lz_key (string, optional; default null): Namespace for the group key; null
    selects client_config.landingzone_key.

Key Vault source:
- value_from_key_vault (object, optional; default null): Retrieves the value
  through the APIM managed identity. Must be set without value, and requires
  secret = true and either secret_id or both key_vault and secret_name. This
  module does not grant vault access.
  - secret_id (string, optional; default null): Key Vault secret URI. Takes
    precedence over constructing a URI from key_vault and secret_name.
  - secret_name (string, optional; default null): Required when secret_id is
    omitted. Used with the referenced vault's vault_uri to construct a
    versionless secret URI.
  - key_vault (object, conditionally required): Vault reference used when
    secret_id is omitted; defaults to null.
    - key (string, required within key_vault): Business key in keyvaults. The
      referenced object must expose vault_uri.
    - lz_key (string, optional; default null): Vault namespace; null selects
      client_config.landingzone_key.
  - identity_client_id (string, optional; default null): Client ID of an APIM
    user-assigned identity authorized to read the secret. Overrides
    managed_identity; it is not an identity resource ID or principal object ID.
  - managed_identity (object, optional; default null): Resolves the identity
    client ID by reference when identity_client_id is omitted. If both are
    omitted, APIM uses its system-assigned identity.
    - key (string, required within managed_identity): Business key in
      managed_identities; the object must expose client_id.
    - lz_key (string, optional; default null): Identity namespace; null selects
      client_config.landingzone_key.

Operation limits:
- timeouts (object, optional; default null): Terraform operation time limits.
  Omission or explicit null omits the block and leaves defaults to the provider.
  - create (string, optional; default null): Maximum creation duration;
    provider default 30m.
  - read (string, optional; default null): Maximum refresh/retrieval duration;
    provider default 5m.
  - update (string, optional; default null): Maximum update duration;
    provider default 30m.
  - delete (string, optional; default null): Maximum deletion duration;
    provider default 30m.
DESCRIPTION
  type = object({
    name                = string
    display_name        = string
    value               = optional(string)
    secret              = optional(bool, false)
    tags                = optional(list(string))
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    value_from_key_vault = optional(object({
      secret_id   = optional(string)
      secret_name = optional(string)
      key_vault = optional(object({
        key    = string
        lz_key = optional(string)
      }))
      identity_client_id = optional(string)
      managed_identity = optional(object({
        key    = string
        lz_key = optional(string)
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = (var.settings.value != null) != (var.settings.value_from_key_vault != null)
    error_message = "Specify exactly one of value or value_from_key_vault."
  }

  validation {
    condition     = var.settings.value_from_key_vault == null || var.settings.secret
    error_message = "secret must be true when value_from_key_vault is configured."
  }

  validation {
    condition = var.settings.value_from_key_vault == null || (
      try(var.settings.value_from_key_vault.secret_id, null) != null ||
      (
        try(var.settings.value_from_key_vault.key_vault, null) != null &&
        try(var.settings.value_from_key_vault.secret_name, null) != null
      )
    )
    error_message = "value_from_key_vault requires secret_id or both key_vault and secret_name."
  }
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}

variable "location" {
  description = "Location of the resource if different from the resource group."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resource group object to deploy the Azure resource."
  type        = any
  default     = null
}

variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
