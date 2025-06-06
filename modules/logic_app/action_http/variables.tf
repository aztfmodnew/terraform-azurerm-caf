variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "Settings object (see module README.md)."
}
variable "logic_app_id" {
  description = "(Required) Specifies the ID of the Logic App Workflow"
}
