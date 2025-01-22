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
Settings object for the static member:
- name: The name of the static member.
- description: The description of the static member.
- network_group: The network group object.
- security_admin_configuration: The security admin configuration object.
- target_virtual_network: The target virtual network object.

```hcl
  type = object({
    name        = string
    description = string
    network_group = object({
      key = string
    })
    security_admin_configuration = object({
      key = string
    })
  })
}
```

Example:

```hcl
  settings = {
    name        = "static_member_1"
    description = "Test Static Member"
    network_group = {
      key = "network_group_1"
    }
    security_admin_configuration
    target_virtual_network = {
      key = "virtual_network_1"
    }
  }
```

DESCRIPTION
  type        = any
}
