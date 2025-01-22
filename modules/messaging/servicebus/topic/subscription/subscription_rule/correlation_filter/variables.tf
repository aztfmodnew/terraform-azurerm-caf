variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "(Required) The configuration for each module"
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
