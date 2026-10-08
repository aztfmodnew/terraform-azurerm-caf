variable "storage_share_url" {
  description = "URL of the Azure Storage File Share in which this directory will be created. This is the current argument expected by azurerm_storage_share_directory in azurerm v5.x."
  type        = string
  default     = null
}

variable "storage_share_id" {
  description = "Deprecated alias kept for backward compatibility. Legacy callers may continue to pass the share URL here; prefer storage_share_url."
  type        = string
  default     = null
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}