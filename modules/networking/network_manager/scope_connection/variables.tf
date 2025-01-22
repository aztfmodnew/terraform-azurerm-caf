variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be passed to the module."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings object for the group connection module:

- name: Name of the group connection
- network_manager_id: ID of the network manager
- network_manager:
  - key: Key of the network manager
  - lz_key: Landing zone key of the network manager
- target_scope_id: ID of the target scope, Subscription ID or Management Group ID
- description: Description of the group connection
- timeouts: Timeouts for the group connection

DESCRIPTION
  type        = any
}