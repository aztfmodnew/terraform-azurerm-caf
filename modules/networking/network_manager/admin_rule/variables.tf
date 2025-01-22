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

  Settings object for the group connection module:

  - name: Name of the group connection
  - admin_rule_collection_id: ID of the admin rule collection
  - admin_rule_collection: Admin rule collection object
    - key: Key of the admin rule collection
    - lz_key: Landing zone key of the admin rule collection
  - action: Action of the admin rule
  - direction: Direction of the admin rule
  - priority: Priority of the admin rule
  - protocol: Protocol of the admin rule
  - description: Description of the admin rule
  - destination_port_ranges: Destination port ranges of the admin rule
  - destination: Destination object
    - address_prefix: Address prefix of the destination
    - address_prefix_type: Address prefix type of the destination
  - source_port_ranges: Source port ranges of the admin rule
  - source: Source object
    - address_prefix: Address prefix of the source
    - address_prefix_type: Address prefix type of the source
  - timeouts: Timeouts for the admin rule

  Example:

  ```hcl
  settings = {
    name                    = "admin_rule_1"
    admin_rule_collection = {
      key = "admin_rule_collection_1"
    }
    action                  = "Allow"
    direction               = "Outbound"
    priority                = 1
    protocol                = "Tcp"
    description             = "Test Admin Rule"
    destination_port_ranges = ["80"]
    destination = [
      {
        address_prefix      = "Internet"
        address_prefix_type = "ServiceTag"
      }
    ]
    source_port_ranges      = ["80", "1024-65535"]
    source = [
      {
        address_prefix      = "Internet"
        address_prefix_type = "ServiceTag"
      }
    ]
    timeouts = {
      create = "30m"
      read   = "5m"
      update = "30m"
      delete = "30m"
    }
  }
  ```
DESCRIPTION
  type        = any
  /* For the future:
  type        = object({
    name                    = string
    admin_rule_collection = object({
      key  = string
      lz_key = string
    })
    action                  = string
    direction               = string
    priority                = number
    protocol                = string
    description             = string
    destination_port_ranges = list(string)
    destination             = list(object({
      address_prefix      = string
      address_prefix_type = string
    }))
    source_port_ranges      = list(string)
    source                  = list(object({
      address_prefix      = string
      address_prefix_type = string
    }))
    timeouts                = object({
      create = string
      read   = string
      update = string
      delete = string
    })
  })
  */
}
