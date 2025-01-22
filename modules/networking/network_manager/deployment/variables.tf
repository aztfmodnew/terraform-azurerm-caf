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
  description = "Settings object"
  type        = any
}
