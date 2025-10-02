variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
# variable "location" {
#   description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
#   type        = string
# }

variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}

variable "keyvaults" {
  description = "Keyvault to store the SSH public and private keys when not provided by the var.public_key_pem_file or retrieve admin username and password"
  default     = ""
}

variable "boot_diagnostics_storage_account" {
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
  default     = null
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
  validation {
    condition = (
      # If shutdown_schedule is not configured -> ok
      try(var.settings.shutdown_schedule, null) == null ||
      # If notifications are not enabled -> ok
      try(var.settings.shutdown_schedule.notification_settings.enabled, false) == false ||
      # If notifications enabled, require either email or webhook_url
      (try(var.settings.shutdown_schedule.notification_settings.enabled, false) == true && (
        try(var.settings.shutdown_schedule.notification_settings.email, null) != null ||
        try(var.settings.shutdown_schedule.notification_settings.webhook_url, null) != null
      ))
    )

    error_message = "When 'shutdown_schedule.notification_settings.enabled' is true you must provide either 'email' or 'webhook_url' in settings.shutdown_schedule.notification_settings."
  }
}

variable "vnets" {}

# Security
variable "public_key_pem_file" {
  default     = ""
  description = "If disable_password_authentication is set to true, ssh authentication is enabled. You can provide a list of file path of the public ssh key in PEM format. If left blank a new RSA/4096 key is created and the key is stored in the keyvault_id. The secret name being the {computer name}-ssh-public and {computer name}-ssh-private"
}

variable "managed_identities" {
  default = {}
}

variable "diagnostics" {
  default = {}
}
variable "public_ip_addresses" {
  default = {}
}

variable "recovery_vaults" {
  default = {}
}

variable "storage_accounts" {
  default = {}
}

variable "availability_sets" {
  default = {}
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "proximity_placement_groups" {
  default = {}
}

variable "disk_encryption_sets" {
  default = {}
}

variable "application_security_groups" {
  default = {}
}

variable "virtual_machines" {
  default = {}
}
variable "image_definitions" {
  default = {}
}
variable "custom_image_ids" {
  default = {}
}
variable "network_security_groups" {
  default     = {}
  description = "Require a version 1 NSG definition to be attached to a nic."
}

variable "dedicated_hosts" {
  default = {}
}

variable "virtual_subnets" {
  description = "Map of virtual_subnets objects"
  default     = {}
  nullable    = false
}
