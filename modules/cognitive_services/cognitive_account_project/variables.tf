variable "global_settings" {
  description = "Global CAF settings."
  type        = any
}

variable "client_config" {
  description = "Client and landing-zone configuration."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings for azurerm_cognitive_account_project:
- name (Required): Project name.
- location (Optional): Region; defaults to the global default region.
- description (Optional): Project description.
- display_name (Optional): Project display name.
- identity (Required by the resource, defaults to SystemAssigned): Managed identity configuration.
  - type: SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned.
  - identity_ids: Direct user-assigned identity resource IDs.
  - managed_identity_keys: Local managed identity keys.
  - remote: Remote landing-zone managed identity references.
- tags (Optional): Project tags.
- timeouts (Optional): create/read/update/delete operation timeouts.
DESCRIPTION
  type        = any
}

variable "cognitive_account_id" {
  description = "ID of an AIServices Cognitive Account with project management enabled."
  type        = string
}

variable "remote_objects" {
  description = "Remote managed identities and other CAF objects."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Whether to inherit global and module tags."
  type        = bool
  default     = false
}
