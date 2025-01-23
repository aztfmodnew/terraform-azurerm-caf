variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "location" {
  description = "The location of the resource."
  type        = string
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be passed to the module."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
  The settings object for network manager:

  - name: (Required) The name of the network manager.
  - scope: (Required) The scope of the network manager.
    - management_group_ids: (Optional) The management group IDs of the network manager.
    - subscription_ids: (Optional) The subscription IDs of the network manager.
  - scope_accesses: (Required) The scope accesses of the network manager.
  - description: (Optional) The description of the network manager.
  - tags: (Optional) A mapping of tags to assign to the resource.


  ```hcl
  object({
    resource_group_key = string
    scope              = any
    scope_accesses     = list(any)
    description        = string
  })
  ```
  example:
  ```hcl
  {
    resource_group_key = "test_re1"
    scope = {
      #"management_group_ids" = []
      #"subscription_ids" = []
      # If you don't specify a subscription ID, the module will use the client_config.subscription_id
    }
    "scope_accesses" = []
    "description" = "Network Manager"
  }
  ```

  DESCRIPTION
  type        = any
}
