variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}


variable "settings" {
  description = "Settings of the module"
  type        = any
}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "Flag to determine if tags should be inherited"
}

variable "remote_objects" {
  type        = any
  description = <<DESCRIPTION
    A map of objects representing the remote objects to be used in the module.
    This is used to pass the remote objects to the module.
    The keys of the map are the names of the remote objects.
    The values of the map are the objects themselves.
  DESCRIPTION
}


variable "private_endpoints" {
  description = "A map of objects representing the private endpoints to create."
  type        = any
  # For the future
  #type        = map(object({
  #  name          = string
  #  lz_key        = string
  #  resource_group_key = string
  #  subnet_id     = optional(string)
  #  vnet_key      = string
  #  subnet_key    = string
  #}))
  default = {}
}