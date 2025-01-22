variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "iothub_id" {
  description = "(Required) The id of the IoT Hub. Changing this forces a new resource to be created"
}
