variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "storage_account_name" {
  description = "Deprecated: use storage_account_id instead. Retained for backward compatibility."
  type        = string
  default     = null
}
variable "storage_account_id" {
  description = "The ID of the Storage Account where the queue should be created."
  type        = string
  default     = null
}
