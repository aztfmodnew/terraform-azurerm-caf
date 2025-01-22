variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "var_folder_path" {
  description = "The path to the folder containing the variables file."
  type        = string
}
variable "storage_account_name" {
  description = "The name of the Storage Account."
  type        = string
  default     = null
}
variable "storage_account_id" {
  description = "The ID of the Storage Account."
  type        = string
  default     = null
}
