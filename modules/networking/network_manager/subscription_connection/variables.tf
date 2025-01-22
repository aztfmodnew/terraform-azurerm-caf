variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be passed to the module."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
The settings object is a map of objects. Each object represents a Network Subscription Network Manager Connection to be created.

  The object has the following attributes:
   - name - (Required) Specifies the name which should be used for this Network Subscription Network Manager Connection. Changing this forces a new Network Subscription Network Manager Connection to be created.
   - subscription_id - (Required) Specifies the ID of the target Subscription. Changing this forces a new resource to be created.
   - network_manager_id - (Required if Network_Manager is not specified) Specifies the ID of the Network Manager which the Subscription is connected to.
   - network_manager - (Required if Network_manager_id is not specified) Specifies the Network Manager which the Subscription is connected to.
     - key - (Required) Specifies the key of the Network Manager which the Subscription is connected to.
     - lz_key - (Required) Specifies the Landing Zone key of the Network Manager which the Subscription is connected to.
   - description - (Optional) A description of the Network Manager Subscription Connection.
   - timeouts - (Optional) A timeouts block as documented below.
     - create - (Optional) Specifies the timeout for creating the Network Manager Subscription Connection.
     - read - (Optional) Specifies the timeout for reading the Network Manager Subscription Connection.
     - delete - (Optional) Specifies the timeout for deleting the Network Manager Subscription Connection.
    - update - (Optional) Specifies the timeout for updating the Network Manager Subscription Connection.

  Example input:

  ```hcl
  settings = {
    name            = "my-network-manager-subscription-connection"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    network_manager = {
      key    = "network-manager-key"
      lz_key = "lz-key"
    }
    description = "My Network Manager Subscription Connection"
    timeouts = {
      create = "10m"
      read   = "10m"
      delete = "10m"
      update = "10m"
    }
  }
  ```
DESCRIPTION
  type        = any
  /* for the tuture
  type = object({
    name            = string
    subscription_id = string
    network_manager = object({
      key     = string
      lz_key  = string
    })
    timeouts = object({
      create = string
      read   = string
      delete = string
      update = string
    })
    description = string
  })
} */
}