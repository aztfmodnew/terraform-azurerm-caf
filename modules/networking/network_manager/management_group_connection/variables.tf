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
- management_group_id: ID of the management group
- description: Description of the group connection
- timeouts: Timeouts for the group connection





DESCRIPTION
  type        = any
}