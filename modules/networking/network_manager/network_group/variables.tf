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
Settings object for the network group.
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
    name        = "network_group_1"
    description = "Test Network Group"
    network_group = {
      key = "network_group_1"
    }
    security_admin_configuration
  }
```

DESCRIPTION
  type        = any
}