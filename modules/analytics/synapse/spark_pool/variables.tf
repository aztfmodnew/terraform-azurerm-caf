variable "settings" {
  description = <<DESCRIPTION
Settings for an Azure Synapse Spark pool.

Required:
  - name - Input name used by CAF naming.
  - node_size_family - Node family: HardwareAcceleratedFPGA, HardwareAcceleratedGPU, MemoryOptimized, or None.
  - node_size - Node size: Small, Medium, Large, None, XLarge, XXLarge, or XXXLarge.

Optional:
  - spark_version - Spark runtime version, either 3.4 or 3.5. Defaults to 3.4.
  - node_count - Fixed node count. Set this or auto_scale, but not both.
  - auto_scale - Minimum and maximum node counts when autoscaling is enabled.
  - auto_pause - Idle delay in minutes before the pool is paused (5-10080).
  - cache_size - Spark pool cache size.
  - compute_isolation_enabled - Enables compute isolation; provider/service restrictions apply.
  - dynamic_executor_allocation_enabled - Enables dynamic Spark executor allocation.
  - min_executors, max_executors - Executor allocation bounds when dynamic allocation is enabled.
  - library_requirement - Optional library requirements file content and filename.
  - session_level_packages_enabled - Enables session-level package support.
  - spark_config - Optional Spark configuration content and filename.
  - spark_log_folder, spark_events_folder - Output folders; default to /logs and /events.
  - tags - Additional tags applied to the Spark pool.
  - timeouts - Create, read, update, and delete operation timeouts.
DESCRIPTION
  type = object({
    name             = string
    node_size_family = string
    node_size        = string
    spark_version    = optional(string, "3.4")
    node_count       = optional(number)
    auto_scale = optional(object({
      max_node_count = number
      min_node_count = number
    }))
    auto_pause = optional(object({
      delay_in_minutes = number
    }))
    cache_size                          = optional(number)
    compute_isolation_enabled           = optional(bool)
    dynamic_executor_allocation_enabled = optional(bool)
    min_executors                       = optional(number)
    max_executors                       = optional(number)
    library_requirement = optional(object({
      content  = string
      filename = string
    }))
    session_level_packages_enabled = optional(bool)
    spark_config = optional(object({
      content  = string
      filename = string
    }))
    spark_log_folder    = optional(string)
    spark_events_folder = optional(string)
    tags                = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = (try(var.settings.node_count, null) != null) != (try(var.settings.auto_scale, null) != null)
    error_message = "Specify exactly one of node_count or auto_scale."
  }

  validation {
    condition = contains(
      ["HardwareAcceleratedFPGA", "HardwareAcceleratedGPU", "MemoryOptimized", "None"],
      var.settings.node_size_family
    )
    error_message = "node_size_family must be HardwareAcceleratedFPGA, HardwareAcceleratedGPU, MemoryOptimized, or None."
  }

  validation {
    condition = contains(
      ["Small", "Medium", "Large", "None", "XLarge", "XXLarge", "XXXLarge"],
      var.settings.node_size
    )
    error_message = "node_size must be Small, Medium, Large, None, XLarge, XXLarge, or XXXLarge."
  }

  validation {
    condition     = contains(["3.4", "3.5"], var.settings.spark_version)
    error_message = "spark_version must be 3.4 or 3.5."
  }

  validation {
    condition = try(var.settings.auto_scale, null) == null ? true : (
      var.settings.auto_scale.min_node_count >= 3 &&
      var.settings.auto_scale.min_node_count <= var.settings.auto_scale.max_node_count &&
      var.settings.auto_scale.max_node_count <= 200
    )
    error_message = "auto_scale node counts must be between 3 and 200, and min_node_count must not exceed max_node_count."
  }

  validation {
    condition = try(var.settings.auto_pause, null) == null ? true : (
      var.settings.auto_pause.delay_in_minutes >= 5 &&
      var.settings.auto_pause.delay_in_minutes <= 10080
    )
    error_message = "auto_pause.delay_in_minutes must be between 5 and 10080."
  }
}

variable "global_settings" {
  description = "Global CAF naming settings."
  type        = any
}

variable "synapse_workspace_id" {
  description = "ID of the parent Synapse workspace."
  type        = string
}

variable "tags" {
  description = "Inherited tags to apply to the Spark pool."
  type        = map(any)
}
