variable "storage_container_id" {
  description = "The ID of the Storage Container in which this blob should be created."
  type        = string
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "var_folder_path" {
  description = "The path to the folder containing the variables file."
  type        = string
}