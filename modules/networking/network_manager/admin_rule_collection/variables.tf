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
Settings object for the admin rule.
```hcl
  type = object({
    admin_rule_collection = object({
      key = string
    })
    name        = string
    description = string
    action      = string
    direction   = string
    priority    = number
    protocol    = string
    source_port_ranges      = list(string)
    destination_port_ranges = list(string)
    source = list(object({
      address_prefix      = string
      address_prefix_type = string
    }))
    destination = list(object({
      address_prefix      = string
      address_prefix_type = string
    }))
  })
}
```
Example:
```hcl
  settings = {
    admin_rule_collection = {
      key = "admin_rule_collection_1"
    }
    name        = "admin_rule_1"
    description = "Test Admin Rule"
    action      = "Allow"
    direction   = "Outbound"
    priority    = 1
    protocol    = "Tcp"
    source_port_ranges      = ["80", "1024-65535"]
    destination_port_ranges = ["80"]
    source = [
      {
        address_prefix      = "Internet"
        address_prefix_type = "ServiceTag"
      }
    ]
    destination = [
      {
        address_prefix_type = "IPPrefix"
        address_prefix      = "10.1.0.1"
      },
      {
        address_prefix_type = "IPPrefix"
        address_prefix      = "10.0.0.0/24"
      }
    ]
    description = "Example Admin Rule"
  }
```
DESCRIPTION
  type        = any
}