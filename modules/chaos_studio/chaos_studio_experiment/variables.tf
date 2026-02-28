variable "global_settings" {
  description = "Global settings object for the CAF framework"
}

variable "client_config" {
  description = "Client configuration object for the CAF framework"
}

variable "location" {
  description = "Azure region where the resource will be created"
  type        = string
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Chaos Studio Experiment. Configuration attributes:
      - name - (Required) Name of the experiment
      - location - (Optional) Azure region for the experiment
      - resource_group - (Required) Resource group reference
        - key - Resource group key
        - lz_key - (Optional) Cross-landing-zone key
      - identity - (Optional) Managed identity configuration
        - type - (Required) Type: "SystemAssigned" or "UserAssigned"
        - managed_identity_keys - (Optional) List of managed identity keys for UserAssigned
      - selectors - (Required) List of selectors
        - name - (Required) Selector name
        - chaos_studio_target_ids - (Optional) Direct list of target IDs
        - chaos_studio_targets - (Optional) List of key-based references
          - key - Target key
          - lz_key - (Optional) Cross-landing-zone key
      - steps - (Required) List of experiment steps
        - name - (Required) Step name
        - branch - (Required) List of branches
          - name - (Required) Branch name
          - actions - (Required) List of actions
            - action_type - (Required) "continuous", "delay", or "discrete"
            - duration - (Optional) ISO8601 duration for continuous/delay
            - parameters - (Optional) Action parameters map
            - selector_name - (Optional) Selector name (required for continuous/discrete)
            - urn - (Optional) Capability URN (required for continuous/discrete)
            - capability - (Optional) Key-based capability reference
              - key - Capability key
              - lz_key - (Optional) Cross-landing-zone key
    DESCRIPTION
  type = object({
    name     = string
    location = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
    }))
    identity = optional(object({
      type                  = string
      managed_identity_keys = optional(list(string), [])
      remote = optional(map(object({
        managed_identity_keys = list(string)
      })), {})
    }))
    selectors = optional(list(object({
      name                    = string
      chaos_studio_target_ids = optional(list(string))
      chaos_studio_targets = optional(list(object({
        key    = string
        lz_key = optional(string)
      })), [])
    })), [])
    steps = optional(list(object({
      name = string
      branch = list(object({
        name = string
        actions = list(object({
          action_type   = string
          duration      = optional(string)
          parameters    = optional(map(string))
          selector_name = optional(string)
          urn           = optional(string)
          capability = optional(object({
            key    = string
            lz_key = optional(string)
          }))
        }))
      }))
    })), [])
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  validation {
    condition     = length(setsubtract(keys(var.settings), ["name", "location", "resource_group", "identity", "selectors", "steps", "tags", "timeouts"])) == 0
    error_message = "Unsupported attributes in settings. Allowed: name, location, resource_group, identity, selectors, steps, tags, timeouts."
  }
}

variable "resource_group" {
  description = "Resource group object for the Chaos Studio Experiment"
}

variable "base_tags" {
  description = "Base tags to be applied to all resources"
  type        = bool
  default     = false
}

variable "remote_objects" {
  description = "Remote objects for dependency resolution"
  type = object({
    resource_groups           = optional(map(any), {})
    chaos_studio_targets      = optional(map(any), {})
    chaos_studio_capabilities = optional(map(any), {})
    managed_identities        = optional(map(any), {})
  })
  default = {}
}
