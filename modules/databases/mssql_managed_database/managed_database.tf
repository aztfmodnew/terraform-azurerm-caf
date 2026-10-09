resource "azapi_resource" "manageddb" {
  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = format("manageddb-%s", azurecaf_name.manageddb.result)
  parent_id = var.resource_group_id
  tags      = local.tags
  location  = try(var.settings.deployment.location, null)
  dynamic "identity" {
    for_each = try(var.settings.deployment.identity, null) == null ? [] : [var.settings.deployment.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }
  body = {
    properties = {
      mode                     = "Incremental"
      externalInputs           = try(var.settings.deployment.external_inputs, null)
      externalInputDefinitions = try(var.settings.deployment.external_input_definitions, null)
      extensionConfigs         = try(var.settings.deployment.extension_configs, null)
      validationLevel          = try(var.settings.deployment.validation_level, null)
      template = merge(jsondecode(file(local.arm_filename)), {
        resources = [
          for index, definition in jsondecode(file(local.arm_filename)).resources :
          index == 0 ? merge(definition, {
            apiVersion = "2025-01-01"
            properties = merge(definition.properties, {
              for key, value in {
                autoCompleteRestore                          = try(var.settings.autoCompleteRestore, null)
                catalogCollation                             = try(var.settings.catalogCollation, null)
                crossSubscriptionRestorableDroppedDatabaseId = try(var.settings.crossSubscriptionRestorableDroppedDatabaseId, null)
                crossSubscriptionSourceDatabaseId            = try(var.settings.crossSubscriptionSourceDatabaseId, null)
                crossSubscriptionTargetManagedInstanceId     = try(var.settings.crossSubscriptionTargetManagedInstanceId, null)
                isLedgerOn                                   = try(var.settings.isLedgerOn, null)
                lastBackupName                               = try(var.settings.lastBackupName, null)
                recoverableDatabaseId                        = try(var.settings.recoverableDatabaseId, null)
                restorableDroppedDatabaseId                  = try(var.settings.restorableDroppedDatabaseId, null)
                storageContainerIdentity                     = try(var.settings.storageContainerIdentity, null)
                storageContainerSasToken                     = try(var.settings.storageContainerSasToken, null)
                storageContainerUri                          = try(var.settings.storageContainerUri, null)
              } : key => value if value != null
            })
          }) : merge(definition, { apiVersion = "2025-01-01" })
        ]
      })
      debugSetting = try(var.settings.deployment.debug_setting_detail_level, null) == null ? null : {
        detailLevel = var.settings.deployment.debug_setting_detail_level
      }
      expressionEvaluationOptions = try(var.settings.deployment.expression_evaluation_scope, null) == null ? null : {
        scope = var.settings.deployment.expression_evaluation_scope
      }
      onErrorDeployment = try(var.settings.deployment.on_error_deployment, null) == null ? null : {
        type           = var.settings.deployment.on_error_deployment.type
        deploymentName = try(var.settings.deployment.on_error_deployment.deployment_name, null)
      }
      parameters = {
        serverName = {
          value = var.server_name
        }
        dbName = {
          value = azurecaf_name.manageddb.result
        }
        location = {
          value = var.location
        }
        collation = {
          value = try(var.settings.collation, "SQL_Latin1_General_CP1_CI_AS")
        }
        createMode = {
          value = try(var.settings.createMode, "Default")
        }
        sourceDatabaseId = {
          value = var.sourceDatabaseId
        }
        restorePointInTime = {
          value = try(var.settings.createMode, null) == "PointInTimeRestore" ? var.settings.restorePointInTime : ""
        }
        longTermRetentionBackupResourceId = {
          value = try(var.settings.longTermRetentionBackupResourceId, "")
        }
        retentionDays = {
          value = try(var.settings.retentionDays, 7)
        }
        tags = {
          value = local.tags
        }
      }
    }
  }

  ignore_null_property   = true
  response_export_values = ["properties.outputs"]

  provisioner "local-exec" {
    when       = destroy
    on_failure = fail
    command = format(
      "az rest --method delete --url https://management.azure.com%s?api-version=2025-01-01",
      self.output.properties.outputs.id.value
    )
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