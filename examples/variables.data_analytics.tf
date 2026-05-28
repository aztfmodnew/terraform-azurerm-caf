# Split from variables.tf - group: data_analytics

variable "mssql_servers" {
  type    = any
  default = {}
}

variable "mssql_managed_instances" {
  type    = any
  default = {}
}

variable "mssql_managed_instances_secondary" {
  type    = any
  default = {}
}

variable "mssql_databases" {
  type    = any
  default = {}
}

variable "mssql_managed_databases" {
  type    = any
  default = {}
}

variable "mssql_managed_databases_restore" {
  type    = any
  default = {}
}

variable "mssql_managed_databases_backup_ltr" {
  type    = any
  default = {}
}

variable "mssql_elastic_pools" {
  type    = any
  default = {}
}

variable "mssql_failover_groups" {
  type    = any
  default = {}
}

variable "mssql_mi_failover_groups" {
  type    = any
  default = {}
}

variable "mssql_mi_administrators" {
  type    = any
  default = {}
}

variable "mssql_mi_tdes" {
  type    = any
  default = {}
}

variable "mssql_mi_secondary_tdes" {
  type    = any
  default = {}
}

variable "synapse_workspaces" {
  type    = any
  default = {}
}

variable "databricks_workspaces" {
  type    = any
  default = {}
}

variable "databricks_access_connectors" {
  type    = any
  default = {}
}

variable "fabric_capacities" {
  type    = any
  default = {}
}

variable "machine_learning_workspaces" {
  type    = any
  default = {}
}

variable "postgresql_flexible_servers" {
  type    = any
  default = {}
}

variable "recovery_vaults" {
  type    = any
  default = {}
}

variable "cosmos_dbs" {
  type    = any
  default = {}
}

variable "database_migration_services" {
  type    = any
  default = {}
}

variable "database_migration_projects" {
  type    = any
  default = {}
}

variable "data_factory" {
  type    = any
  default = {}
}

variable "data_factory_pipeline" {
  type    = any
  default = {}
}

variable "data_factory_trigger_schedule" {
  type    = any
  default = {}
}

variable "data_factory_dataset_azure_blob" {
  type    = any
  default = {}
}

variable "data_factory_dataset_cosmosdb_sqlapi" {
  type    = any
  default = {}
}

variable "data_factory_dataset_delimited_text" {
  type    = any
  default = {}
}

variable "data_factory_dataset_http" {
  type    = any
  default = {}
}

variable "data_factory_dataset_json" {
  type    = any
  default = {}
}

variable "data_factory_dataset_mysql" {
  type    = any
  default = {}
}

variable "data_factory_dataset_postgresql" {
  type    = any
  default = {}
}

variable "data_factory_dataset_sql_server_table" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_azure_blob_storage" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_cosmosdb" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_web" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_mysql" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_postgresql" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_sql_server" {
  type    = any
  default = {}
}

variable "data_factory_linked_service_azure_databricks" {
  type    = any
  default = {}
}

variable "kusto_clusters" {
  type    = any
  default = {}
}

variable "kusto_databases" {
  type    = any
  default = {}
}

variable "kusto_attached_database_configurations" {
  type    = any
  default = {}
}

variable "kusto_cluster_customer_managed_keys" {
  type    = any
  default = {}
}

variable "kusto_cluster_principal_assignments" {
  type    = any
  default = {}
}

variable "kusto_database_principal_assignments" {
  type    = any
  default = {}
}

variable "kusto_eventgrid_data_connections" {
  type    = any
  default = {}
}

variable "kusto_eventhub_data_connections" {
  type    = any
  default = {}
}

variable "kusto_iothub_data_connections" {
  type    = any
  default = {}
}

variable "machine_learning_compute_instance" {
  type    = any
  default = {}
}

variable "data_factory_integration_runtime_self_hosted" {
  type    = any
  default = {}
}

variable "data_factory_integration_runtime_azure_ssis" {
  type    = any
  default = {}
}

variable "mysql_flexible_server" {
  type    = any
  default = {}
}

variable "purview_accounts" {
  type    = any
  default = {}
}

variable "cosmosdb_sql_databases" {
  type    = any
  default = {}
}

variable "backup_vaults" {
  type    = any
  default = {}
}

variable "backup_vault_policies" {
  type    = any
  default = {}
}

variable "backup_vault_instances" {
  type    = any
  default = {}
}

variable "cosmosdb_role_mapping" {
  type    = any
  default = {}
}

variable "cosmosdb_role_definitions" {
  type    = any
  default = {}
}

variable "search_services" {
  type    = any
  default = {}
}
