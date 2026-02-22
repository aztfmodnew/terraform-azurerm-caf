variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = "Invoice section settings object"
  type        = any
}

variable "base_tags" {
  description = "Base tags to inherit from global settings."
  type        = bool
  default     = false
}
