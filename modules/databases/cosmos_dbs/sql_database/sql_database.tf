## Cosmos DB SQL API

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create database
resource "azurerm_cosmosdb_sql_database" "database" {
  name                = try(var.settings.add_rnd_num, true) == false ? var.settings.name : format("%s-%s", var.settings.name, random_integer.ri.result)
  resource_group_name = var.resource_group_name
  account_name        = var.cosmosdb_account_name
  # Note : throughput and autoscale_settings conflict and autoscale_settings will take precedence if set
  throughput = try(var.settings.autoscale_settings, null) != null ? null : try(var.settings.throughput, null)

  # Note : throughput and autoscale_settings conflict and autoscale_settings will take precedence if set
  dynamic "autoscale_settings" {
    for_each = try(var.settings.autoscale_settings, null) != null ? [var.settings.autoscale_settings] : []

    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

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

# Create container
resource "azurerm_cosmosdb_sql_container" "container" {
  for_each = var.settings.containers

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  account_name           = var.cosmosdb_account_name
  database_name          = azurerm_cosmosdb_sql_database.database.name
  partition_key_paths    = each.value.partition_key_paths
  partition_key_kind     = try(each.value.partition_key_kind, null)
  partition_key_version  = try(each.value.partition_key_version, null)
  analytical_storage_ttl = try(each.value.analytical_storage_ttl, null)
  # Note : throughput and autoscale_settings conflict and autoscale_settings will take precedence if set
  throughput  = try(each.value.autoscale_settings, null) != null ? null : try(each.value.throughput, null)
  default_ttl = try(each.value.default_ttl, -1)

  dynamic "unique_key" {
    for_each = try(each.value.unique_key, null) != null ? [each.value.unique_key] : []

    content {
      paths = unique_key.value.paths
    }
  }

  # Note : throughput and autoscale_settings conflict and autoscale_settings will take precedence if set
  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []

    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  dynamic "indexing_policy" {
    for_each = try(each.value.indexing_policy, null) != null ? [each.value.indexing_policy] : []

    content {
      indexing_mode = try(indexing_policy.value.indexing_mode, null)

      dynamic "included_path" {
        for_each = try(indexing_policy.value.included_paths, {})

        content {
          path = included_path.value
        }
      }

      dynamic "excluded_path" {
        for_each = try(indexing_policy.value.excluded_paths, {})

        content {
          path = excluded_path.value
        }
      }

      dynamic "spatial_index" {
        for_each = try(indexing_policy.value.spatial_indexes, {})

        content {
          path = spatial_index.value
        }
      }

      dynamic "composite_index" {
        for_each = try(indexing_policy.value.composite_indexes, {})

        content {
          dynamic "index" {
            for_each = composite_index.value

            content {
              path  = index.value.path
              order = index.value.order
            }
          }
        }
      }
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = try(each.value.conflict_resolution_policy, null) == null ? [] : [each.value.conflict_resolution_policy]

    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = try(conflict_resolution_policy.value.conflict_resolution_path, null)
      conflict_resolution_procedure = try(conflict_resolution_policy.value.conflict_resolution_procedure, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
