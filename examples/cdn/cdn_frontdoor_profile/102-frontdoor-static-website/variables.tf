# Global settings
variable "global_settings" {
  description = "Global settings for naming conventions and tags"
  type        = any
  default     = {}
}

# Resource groups
variable "resource_groups" {
  description = "Resource groups configuration"
  type        = any
  default     = {}
}

# Storage accounts
variable "storage_accounts" {
  description = "Storage accounts configuration for static website hosting"
  type        = any
  default     = {}
}

# Storage containers
variable "storage_containers" {
  description = "Storage containers configuration"
  type        = any
  default     = {}
}

# Storage account blobs
variable "storage_account_blobs" {
  description = "Storage account blobs for website content"
  type        = any
  default     = {}
}

# CDN Front Door Profiles
variable "cdn_frontdoor_profiles" {
  description = "CDN Front Door profiles configuration"
  type        = any
  default     = {}
}

# Log Analytics
variable "log_analytics" {
  description = "Log Analytics workspaces configuration"
  type        = any
  default     = {}
}

# Diagnostics definition
variable "diagnostics_definition" {
  description = "Diagnostics definition for monitoring"
  type        = any
  default     = {}
}

# Diagnostics destinations  
variable "diagnostics_destinations" {
  description = "Diagnostics destinations configuration"
  type        = any
  default     = {}
}
