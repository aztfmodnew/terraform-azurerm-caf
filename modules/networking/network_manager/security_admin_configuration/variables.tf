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
Settings object for the security admin configuration.
```hcl
  type = object({
    name        = string
    description = string
    network_groups = map(object({
      key = string
    }))
  })
```

Example:

```hcl
  settings = {
    name        = "security_admin_configuration_1"
    description = "Test Security Admin Configuration"
    network_groups = {
      network_group_1 = {
        key = "network_group_1"
      }
    }
  }
```

DESCRIPTION
  type        = any
}