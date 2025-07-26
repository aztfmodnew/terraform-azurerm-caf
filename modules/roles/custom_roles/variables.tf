variable "custom_role" {
  type = any
}
variable "subscription_primary" {
  type = any
}
variable "assignable_scopes" {
  type    = list(string)
  default = []
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "Settings object for the custom role"
  type        = any
}
