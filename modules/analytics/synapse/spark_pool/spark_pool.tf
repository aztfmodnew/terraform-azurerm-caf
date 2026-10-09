resource "azurecaf_name" "sparkpool" {
  name          = var.settings.name
  resource_type = "azurerm_synapse_spark_pool"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool
# Tested with: AzureRM provider 5.9.0

resource "azurerm_synapse_spark_pool" "spark_pool" {
  name                                = azurecaf_name.sparkpool.result
  synapse_workspace_id                = var.synapse_workspace_id
  node_size_family                    = var.settings.node_size_family
  node_size                           = var.settings.node_size
  node_count                          = try(var.settings.node_count, null)
  spark_log_folder                    = coalesce(try(var.settings.spark_log_folder, null), "/logs")
  spark_events_folder                 = coalesce(try(var.settings.spark_events_folder, null), "/events")
  spark_version                       = var.settings.spark_version
  cache_size                          = try(var.settings.cache_size, null)
  compute_isolation_enabled           = coalesce(try(var.settings.compute_isolation_enabled, null), false)
  dynamic_executor_allocation_enabled = coalesce(try(var.settings.dynamic_executor_allocation_enabled, null), false)
  min_executors                       = try(var.settings.min_executors, null)
  max_executors                       = try(var.settings.max_executors, null)
  session_level_packages_enabled      = coalesce(try(var.settings.session_level_packages_enabled, null), false)

  dynamic "auto_scale" {
    for_each = try(var.settings.auto_scale, null) == null ? [] : [var.settings.auto_scale]

    content {
      max_node_count = auto_scale.value.max_node_count
      min_node_count = auto_scale.value.min_node_count
    }
  }

  dynamic "auto_pause" {
    for_each = try(var.settings.auto_pause, null) == null ? [] : [var.settings.auto_pause]

    content {
      delay_in_minutes = auto_pause.value.delay_in_minutes
    }
  }

  dynamic "library_requirement" {
    for_each = try(var.settings.library_requirement, null) == null ? [] : [var.settings.library_requirement]

    content {
      content  = library_requirement.value.content
      filename = library_requirement.value.filename
    }
  }
  dynamic "spark_config" {
    for_each = try(var.settings.spark_config, null) != null ? [var.settings.spark_config] : []
    content {
      content  = spark_config.value.content
      filename = spark_config.value.filename
    }
  }
  tags = local.tags

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
