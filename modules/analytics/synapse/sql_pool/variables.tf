variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "synapse_workspace_id" {
  type = string
}
variable "tags" {
  description = "(Required) Map of tags to be applied to the resource"
  type        = map(any)
}

