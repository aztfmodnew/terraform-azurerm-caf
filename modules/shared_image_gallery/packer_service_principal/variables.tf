# trunk-ignore(tflint/terraform_unused_declarations)
variable "client_config" {
  type = any
}
# trunk-ignore(tflint/terraform_unused_declarations)
variable "global_settings" {
  type = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "gallery_name" {
  type = string
}
variable "image_name" {
  type = string
}
variable "key_vault_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "subscription" {
  type = string
}
variable "resource_group" {
  description = "Resource group object"
  type        = any
}

# trunk-ignore(tflint/terraform_unused_declarations)
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
