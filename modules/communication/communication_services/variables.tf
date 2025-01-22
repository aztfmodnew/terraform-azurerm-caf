variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
# trunk-ignore(tflint/terraform_unused_declarations)
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "(Required) Used to handle passthrough paramenters."
  type        = any
}
# trunk-ignore(tflint/terraform_unused_declarations)
variable "remote_objects" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  default     = {}
  type        = map(any)
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "resource_group_name" {
  description = " The name of the Resource Group where the Communication Service should exist. Changing this forces a new Communication Service to be created."
  type        = string
}