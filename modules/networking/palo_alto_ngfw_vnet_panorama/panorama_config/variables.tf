variable "panorama_server_1" {
  description = "(Optional) The primary Panorama server IP address or FQDN."
  type        = string
  default     = null
}

variable "panorama_server_2" {
  description = "(Optional) The secondary Panorama server IP address or FQDN."
  type        = string
  default     = null
}

variable "panorama_virtual_machine_ssh_key" {
  description = "(Optional) The SSH Key for the Panorama virtual machine. Only used if deploying Panorama within this module (not typical for this NGFW resource)."
  type        = string
  default     = null
  sensitive   = true
}

variable "panorama_device_group_name" {
  description = "(Optional) The name of the device group in Panorama."
  type        = string
  default     = null
}

variable "panorama_template_name" {
  description = "(Optional) The name of the template stack in Panorama."
  type        = string
  default     = null
}

variable "panorama_host_name" {
  description = "(Optional) The hostname of the Panorama instance."
  type        = string
  default     = null
}

# Add any other specific Panorama configuration strings you might need to pass to the NGFW resource
